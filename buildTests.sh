#!/bin/bash

#/**
#* Copyright IBM Corporation 2016
#*
#* Licensed under the Apache License, Version 2.0 (the "License");
#* you may not use this file except in compliance with the License.
#* You may obtain a copy of the License at
#*
#* http://www.apache.org/licenses/LICENSE-2.0
#*
#* Unless required by applicable law or agreed to in writing, software
#* distributed under the License is distributed on an "AS IS" BASIS,
#* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#* See the License for the specific language governing permissions and
#* limitations under the License.
#**/

SCRIPT_DIR=$(dirname "$BASH_SOURCE")
cd "$SCRIPT_DIR"

if [ -f "./mainBuildTests.sh" ]; then
    if [ -x "./mainBuildTests.sh" ]; then
        ./mainBuildTests.sh
    else
        echo "Main test builder script isn't executable"
        exit 1
    fi
else
    fwDir="!"
    for  dir in Packages/Kitura-TestFramework* ; do
        fwDir=$dir
    done
    if [[ "${fwDir}" !=  "!"  &&  -d "${fwDir}" ]]; then
        "${fwDir}/TestFramework/mainBuildTests.sh"
    else
        echo "Could not find the Kitura test framework!"
        exit 1
    fi
fi
