#
# Copyright 2024 Canonical, Ltd.
#

import pytest
from k8s_test_harness.util import docker_util, env_util


@pytest.mark.parametrize("image_version", ["1.11.3"])
def test_sanity(image_version):
    rock = env_util.get_build_meta_info_for_rock_version(
        "coredns", image_version, "amd64"
    )
    image = rock.image
    entrypoint = "/coredns"

    process = docker_util.run_in_docker(image, [entrypoint, "--version"])
    assert f"CoreDNS-{image_version}" in process.stdout
