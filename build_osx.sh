#!/bin/bash

##
# Copyright IBM Corporation 2016
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##

# This script builds the Kitura sample app on OS X (Travis CI).
# Homebrew (http://brew.sh/) must be installed on the OS X system for this
# script to work.

# If any commands fail, we want the shell script to exit immediately.
set -e

# Variables
SWIFT_SNAPSHOT=swift-DEVELOPMENT-SNAPSHOT-2016-02-08-a

# Install system level dependencies for Kitura
brew update
brew install --force http-parser pcre2 curl hiredis wget

# Install Swift binaries
# See http://apple.stackexchange.com/questions/72226/installing-pkg-with-terminal
wget https://swift.org/builds/development/xcode/$SWIFT_SNAPSHOT/$SWIFT_SNAPSHOT-osx.pkg
sudo installer -pkg $SWIFT_SNAPSHOT-osx.pkg -target /
export PATH=/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin:"${PATH}"

# Build kitura
echo ">> About to build Kitura..."
make

# Execute test cases for Kitura
echo ">> About to build and execute test cases for Kitura..."
cd ./buildTests.sh && ./runTests.sh
echo ">> Build and execution of test cases completed (see above for results)."
