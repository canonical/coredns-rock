# Contributing

To make contributions to this rock, the only significant changes to be made are in the `Makefile` and the `build/` directory

## Upgrading the components

To Upgrade the rocks for new releases of coredns run the following make target:

```shell
make update-component
```

* if `jq` or `yq` are not installed on the system, they will be when the target for those items runs
* this will clone the upstream coredns/coredns repo only for listing tags
* it will create a new rockcraft yaml based on the tags missing from this repo
* Raise a PR from a branch with the new rockcraft.yaml files


## Testing

To test the rocks, run the pytest sanity check test

```shell
cd tests
tox -e sanity
```
