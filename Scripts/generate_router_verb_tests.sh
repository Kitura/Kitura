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

INPUT_FILE=$1
OUTPUT_FILE=$2

echo "--- Generating ${OUTPUT_FILE}"

cat <<'EOF' > ${OUTPUT_FILE}
/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import XCTest
import Foundation
import SwiftyJSON

@testable import Kitura
@testable import KituraNet

#if os(Linux)
import Glibc
#else
import Darwin
#endif

class TestRouterHTTPVerbsGenerated: KituraTest {

    static var allTests: [(String, (TestRouterHTTPVerbsGenerated) -> () throws -> Void)] {
        return [
            ("testFirstTypeVerbsAdded", testFirstTypeVerbsAdded),
            ("testSecondTypeVerbsAdded", testSecondTypeVerbsAdded),
            ("testThirdTypeVerbsAdded", testThirdTypeVerbsAdded),
            ("testFourthTypeVerbsAdded", testFourthTypeVerbsAdded)
        ]
    }

    let bodyTestHandler: RouterHandler = { request, response, next in
        guard let requestBody = request.body else {
            next ()
            return
        }
        next()
    }

    // check that all verbs with bodyTestHandler parameter was added to elements array
    func testFirstTypeVerbsAdded() {
            let router = Router()
            var verbsArray: [String] = []
EOF
            for VERB in `sed '/^$/d' ${INPUT_FILE} | sed '/^#/d'`; do
                VERB_LOW_CASE=`echo $VERB | cut -c1 | tr '[:upper:]' '[:lower:]'``echo $VERB | cut -c2-`
                VERB_UPPER_CASE=`echo $VERB | tr '[:lower:]' '[:upper:]'`
cat <<EOF >> ${OUTPUT_FILE}
            verbsArray.append("$VERB_UPPER_CASE")
            router.$VERB_LOW_CASE("/bodytest", handler: self.bodyTestHandler)
EOF
            done
cat <<EOF >> ${OUTPUT_FILE}

            // check all verbs added
            let elements = router.elements
            guard elements.count == 27 else {
                XCTFail("didn't add all verbs")
                return
            }
            // check right verbs added
            for index in 0...elements.count - 1 {
                guard elements[index].method.description == verbsArray[index] else {
                    XCTFail("didn't add all verbs")
                    return
                }
            }
    }

    func testSecondTypeVerbsAdded() {
            let router = Router()
            var verbsArray: [String] = []
EOF
            for VERB in `sed '/^$/d' ${INPUT_FILE} | sed '/^#/d'`; do
                VERB_LOW_CASE=`echo $VERB | cut -c1 | tr '[:upper:]' '[:lower:]'``echo $VERB | cut -c2-`
                VERB_UPPER_CASE=`echo $VERB | tr '[:lower:]' '[:upper:]'`
cat <<EOF >> ${OUTPUT_FILE}
            verbsArray.append("$VERB_UPPER_CASE")
            router.$VERB_LOW_CASE("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
EOF
            done
cat <<EOF >> ${OUTPUT_FILE}

            // check all verbs added
            let elements = router.elements
            guard elements.count == 27 else {
                XCTFail("didn't add all verbs")
                return
            }
            // check right verbs added
            for index in 0...elements.count - 1 {
                guard elements[index].method.description == verbsArray[index] else {
                    XCTFail("didn't add all verbs")
                    return
                }
            }
    }

    func testThirdTypeVerbsAdded() {
            let router = Router()
            var verbsArray: [String] = []
            let bodyParser = BodyParser()
EOF
            for VERB in `sed '/^$/d' ${INPUT_FILE} | sed '/^#/d'`; do
                VERB_LOW_CASE=`echo $VERB | cut -c1 | tr '[:upper:]' '[:lower:]'``echo $VERB | cut -c2-`
                VERB_UPPER_CASE=`echo $VERB | tr '[:lower:]' '[:upper:]'`
cat <<EOF >> ${OUTPUT_FILE}
            verbsArray.append("$VERB_UPPER_CASE")
            router.$VERB_LOW_CASE("/bodytest", middleware: bodyParser)
EOF
            done
cat <<EOF >> ${OUTPUT_FILE}

            // check all verbs added
            let elements = router.elements
            guard elements.count == 27 else {
                XCTFail("didn't add all verbs")
                return
            }
            // check right verbs added
            for index in 0...elements.count - 1 {
                guard elements[index].method.description == verbsArray[index] else {
                    XCTFail("didn't add all verbs")
                    return
                }
            }
    }

    func testFourthTypeVerbsAdded() {
            let router = Router()
            var verbsArray: [String] = []
            let bodyParser = BodyParser()
EOF
            for VERB in `sed '/^$/d' ${INPUT_FILE} | sed '/^#/d'`; do
                VERB_LOW_CASE=`echo $VERB | cut -c1 | tr '[:upper:]' '[:lower:]'``echo $VERB | cut -c2-`
                VERB_UPPER_CASE=`echo $VERB | tr '[:lower:]' '[:upper:]'`
cat <<EOF >> ${OUTPUT_FILE}
            verbsArray.append("$VERB_UPPER_CASE")
            router.$VERB_LOW_CASE("/bodytest", middleware: [bodyParser, bodyParser])
EOF
            done
cat <<EOF >> ${OUTPUT_FILE}

            // check all verbs added
            let elements = router.elements
            guard elements.count == 27 else {
                XCTFail("didn't add all verbs")
                return
            }
            // check right verbs added
            for index in 0...elements.count - 1 {
                guard elements[index].method.description == verbsArray[index] else {
                    XCTFail("didn't add all verbs")
                    return
                }
            }
    }
}
