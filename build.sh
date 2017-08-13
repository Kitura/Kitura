#!/bin/bash

set -o verbose

if [ -n "${DOCKER_IMAGE}" ]; then
    docker pull ${DOCKER_IMAGE}
    docker run --env SWIFT_SNAPSHOT -v ${TRAVIS_BUILD_DIR}:${TRAVIS_BUILD_DIR} ${DOCKER_IMAGE} /bin/bash -c "apt-get update && apt-get install -y git sudo lsb-release wget libxml2 && cd $TRAVIS_BUILD_DIR && ./build.sh"
else
    git clone https://github.com/IBM-Swift/Package-Builder.git
    ./Package-Builder/build-package.sh -projectDir $(pwd)
fi
