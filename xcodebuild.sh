#! /bin/bash

SCHEME=Kitura

OS=`uname`
if [[ $OS == "Darwin" ]]; then
    XCODEBUILD_VERSION=`xcodebuild -version`
    echo "Starting xcodebuild (${XCODEBUILD_VERSION}) on ${OS}"
else
    echo "Skipping xcodebuild as not available on ${OS}"
    exit 0
fi

swift package generate-xcodeproj
PROJECT="${SCHEME}.xcodeproj"

TEST_CMD="xcodebuild -project $PROJECT -scheme $SCHEME -sdk macosx -enableCodeCoverage YES test"
echo "Running ${TEST_CMD}"
eval "${TEST_CMD}"

bash <(curl -s https://codecov.io/bash) -J "^${SCHEME}\$"

echo "Finished xcodebuild on ${OS}"
