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

// MARK Router

extension Router {
EOF

for VERB in `sed '/^$/d' ${INPUT_FILE} | sed '/^#/d'`; do
VERB_LOW_CASE=`echo $VERB | cut -c1 | tr '[:upper:]' '[:lower:]'``echo $VERB | cut -c2-`
cat <<EOF >> ${OUTPUT_FILE}
    // MARK: $VERB

    @discardableResult
    public func $VERB_LOW_CASE(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.$VERB_LOW_CASE, pattern: path, handler: handler)
    }

    @discardableResult
    public func $VERB_LOW_CASE(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.$VERB_LOW_CASE, pattern: path, handler: handler)
    }

    @discardableResult
    public func $VERB_LOW_CASE(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.$VERB_LOW_CASE, pattern: path, middleware: middleware)
    }

    @discardableResult
    public func $VERB_LOW_CASE(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.$VERB_LOW_CASE, pattern: path, middleware: middleware)
    }
EOF
done
echo "}" >> ${OUTPUT_FILE}
