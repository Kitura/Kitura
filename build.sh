#!/bin/bash

set -o verbose

if [ -n "${DOCKER_IMAGE}" ]; then
    docker pull ${DOCKER_IMAGE}
    docker run --env SWIFT_VERSION -v ${TRAVIS_BUILD_DIR}:${TRAVIS_BUILD_DIR} ${DOCKER_IMAGE} /bin/bash -c "apt-get update && apt-get install -y git sudo lsb-release wget libxml2 && cd $TRAVIS_BUILD_DIR && ./build.sh"
else
    test -n "${SWIFT_VERSION}" && echo "${SWIFT_VERSION}" > .swift-version || echo "SWIFT_VERSION not set, using $(cat .swift-version)"
    git clone https://github.com/IBM-Swift/Package-Builder.git

    # this line messes up PATH and breaks the build in ubuntu 16.04, comment it out till we get it fixed
    sed -i.bak '/^export PATH=.*\/clang\//s/^/#/' Package-Builder/linux/install_swift_binaries.sh
    diff Package-Builder/linux/install_swift_binaries.sh*

    ./Package-Builder/build-package.sh -projectDir $(pwd)
fi
