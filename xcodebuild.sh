#! /bin/bash

SCHEME=Kitura
SDK=macosx10.12

OS=`uname`
if [[ $OS != "Darwin" ]]; then
    echo "Skipping xcodebuild as not available on ${OS}"
    exit 0
fi

swift package generate-xcodeproj
PROJECT="${SCHEME}.xcodeproj"

TEST_CMD="xcodebuild -scheme $SCHEME -project $PROJECT -sdk $SDK -destination 'arch=x86_64' -enableCodeCoverage YES test"

which -s xcpretty
XCPRETTY_INSTALLED=$?

if [[ $TRAVIS || $XCPRETTY_INSTALLED == 0 ]]; then
  echo "Running ${TEST_CMD} | xcpretty"
  eval "${TEST_CMD} | xcpretty"
else
  echo "xcpretty not installed. Running ${TEST_CMD}"
  eval "${TEST_CMD}"
fi
