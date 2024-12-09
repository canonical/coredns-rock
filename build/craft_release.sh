#!/bin/bash

# This script is used to create a new release rock image from the included template
set -eu

RO_SCRIPT_DIR="$( dirname "${BASH_SOURCE[0]}")"
RO_REPO_DIR=$(dirname ${RO_SCRIPT_DIR})
RO_VERSIONS=${RO_SCRIPT_DIR}/../versions.txt

function check_environment() {
    if [[ -z ${COREDNS_GIT_DIR+x} ]]; then
        echo "COREDNS_GIT_DIR is not set" >&2
        echo "   Clone with 'git clone --bare --filter=blob:none --no-checkout https://github.com/coredns/coredns.git /tmp/coredns.git'" >&2
        echo "   Re-run with 'COREDNS_GIT_DIR=/tmp/coredns.git $0'" >&2
        exit 1
    fi
}


function check_dependencies(){
    for cmd in yq jq git envsubst; do
        if ! command -v $cmd &> /dev/null; then
            echo "$cmd could not be found" >&2
            exit 1
        fi
    done
}


function create_rockcrafts(){
    # Get the current releases from existing rockcraft yamls
    if [[ -v GITHUB_WORKSPACE ]]; then
        echo "::group::Create rockcrafts"
    fi

    rm -rf ${RO_VERSIONS}
    for rockcraft in $(find ${RO_REPO_DIR} -name 'rockcraft.yaml'); do
        # output is piped through echo to work through yq confinement
        echo $(yq '.version' $rockcraft) >> ${RO_VERSIONS}
    done
    current_releases=( $(sort -V ${RO_VERSIONS}) )
    min_tag="v${current_releases[0]}"   # this is the oldest release tag we support
    rm -rf ${RO_VERSIONS}

    # Get the tags from the coredns repo, ignoring all before the min_tag
    coredns_tags=( $(git -C ${COREDNS_GIT_DIR} tag --sort=v:refname | sed -n '/'${min_tag}'/,$p') )
    new_tags=()

    for coredns_tag in "${coredns_tags[@]}"; do
        if [[ ! -e ${RO_REPO_DIR}/${coredns_tag:1}/rockcraft.yaml ]]; then
            new_tag=${coredns_tag:1}
            new_tags+=($new_tag)
            echo "Creating rockcraft.yaml for ${new_tag}"
            mkdir -p ${RO_REPO_DIR}/${new_tag}
            unset ignored_template_var
            tag=${new_tag} envsubst < ${RO_SCRIPT_DIR}/template/rockcraft.yaml.in > ${RO_REPO_DIR}/${new_tag}/rockcraft.yaml
        else
            echo "Skipping ${coredns_tag} as it already exists"
        fi
    done

    if [ ${#new_tags[@]} -eq 0 ]; then
        tags='[]'
    else
        tags=$(printf '%s\n' "${new_tags[@]}" | jq -R . | jq --compact-output -s .)
    fi
    if [[ -v GITHUB_OUTPUT ]]; then
        echo "tags=$tags" >> $GITHUB_OUTPUT
    fi
    if [[ -v GITHUB_WORKSPACE ]]; then
        echo "::endgroup::"
    fi

}


function main() {
    check_environment
    check_dependencies
    create_rockcrafts
}

main