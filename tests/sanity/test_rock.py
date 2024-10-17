#
# Copyright 2024 Canonical, Ltd.
#

from pathlib import Path

import pytest
import yaml
from k8s_test_harness.util import docker_util, env_util

ROCKCRAFT = Path(__file__).parent.parent.parent / "rockcraft.yaml"
VERSION = yaml.safe_load(ROCKCRAFT.open())["version"]


@pytest.mark.parametrize("image_version", [VERSION])
def test_sanity(image_version):
    rock = env_util.get_build_meta_info_for_rock_version(
        "coredns", image_version, "amd64"
    )
    image = rock.image
    entrypoint = "/coredns"

    process = docker_util.run_in_docker(image, [entrypoint, "--version"])
    assert f"CoreDNS-{image_version}" in process.stdout
