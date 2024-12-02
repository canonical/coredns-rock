#!/bin/bash

# This script is used to create a new release rock image from the included template
set -eu

SCRIPT_DIR="$( dirname "${BASH_SOURCE[0]}")"
REPO_DIR=$(dirname ${SCRIPT_DIR})
VERSIONS=${SCRIPT_DIR}/../versions.txt

function usage() {
    if [[ -z ${COREDNS_GIT_DIR+x} ]]; then
        echo "COREDNS_GIT_DIR is not set" > /dev/stderr
        echo "   Clone with 'git clone --bare --filter=blob:none --no-checkout https://github.com/coredns/coredns.git /tmp/coredns.git'" > /dev/stderr
        echo "   Re-run with 'COREDNS_GIT_DIR=/tmp/coredns.git $0'" > /dev/stderr
        exit 1
    fi
}

function create_rockcrafts(){
    # Get the current releases from existing rockcraft yamls
    if [[ -v GITHUB_WORKSPACE ]]; then
        echo "::group::Create rockcrafts"
    fi

    rm -rf ${VERSIONS}
    for rockcraft in $(find ${REPO_DIR} -name 'rockcraft.yaml'); do
        echo $(yq '.version' $rockcraft) >> ${VERSIONS}
    done
    current_releases=( $(sort -V ${VERSIONS}) )
    min_tag="v${current_releases[0]}"   # this is the oldest release tag we support
    rm -rf ${VERSIONS}

    # Get the tags from the coredns repo, ignoring all before the min_tag
    coredns_tags=( $(git -C ${COREDNS_GIT_DIR} tag --sort=v:refname | sed -n '/'${min_tag}'/,$p') )
    new_tags=()

    for coredns_tag in "${coredns_tags[@]}"; do
        if [[ ! -e ${REPO_DIR}/${coredns_tag:1}/rockcraft.yaml ]]; then
            new_tag=${coredns_tag:1}
            new_tags+=($new_tag)
            echo "Creating rockcraft.yaml for ${new_tag}"
            mkdir -p ${REPO_DIR}/${new_tag}
            unset ignored_template_var
            tag=${new_tag} envsubst < ${SCRIPT_DIR}/template/rockcraft.yaml.in > ${REPO_DIR}/${new_tag}/rockcraft.yaml
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
    usage
    create_rockcrafts
}

main