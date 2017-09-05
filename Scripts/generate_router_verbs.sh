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
VERB_UPPER_CASE=`echo $VERB | tr '[:lower:]' '[:upper:]'`
if [ "${VERB_UPPER_CASE}" == "ALL" ]; then
  DOC_TEXT_1="any" 
  DOC_TEXT_2=""
else
  DOC_TEXT_1="HTTP $VERB_UPPER_CASE"
  DOC_TEXT_2="s"
fi
cat <<EOF >> ${OUTPUT_FILE}
    // MARK: $VERB

    /// Setup a set of one or more closures of the type \`RouterHandler\` that will be
    /// invoked when $DOC_TEXT_1 request$DOC_TEXT_2 comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of \`RouterHandler\`s that will be
    ///                     invoked when $DOC_TEXT_1 request$DOC_TEXT_2 comes to the server.
    @discardableResult
    public func $VERB_LOW_CASE(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.$VERB_LOW_CASE, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type \`RouterHandler\` that will be
    /// invoked when $DOC_TEXT_1 request$DOC_TEXT_2 comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of \`RouterHandler\`s that will be
    ///                     invoked when $DOC_TEXT_1 request$DOC_TEXT_2 comes to the server.
    @discardableResult
    public func $VERB_LOW_CASE(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.$VERB_LOW_CASE, pattern: path, handler: handler)
    }

    /// Setup a set of one or more \`RouterMiddleware\` that will be
    /// invoked when $DOC_TEXT_1 request$DOC_TEXT_2 comes to the server. If a path pattern is
    /// specified, the \`RouterMiddleware\` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the \`RouterMiddleware\` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of \`RouterMiddleware\` that will be
    ///                     invoked when $DOC_TEXT_1 request$DOC_TEXT_2 comes to the server.
    @discardableResult
    public func $VERB_LOW_CASE(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.$VERB_LOW_CASE, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more \`RouterMiddleware\` that will be
    /// invoked when $DOC_TEXT_1 request$DOC_TEXT_2 comes to the server. If a path pattern is
    /// specified, the \`RouterMiddleware\` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the \`RouterMiddleware\` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of \`RouterMiddleware\` that will be
    ///                     invoked when $DOC_TEXT_1 request$DOC_TEXT_2 comes to the server.
    @discardableResult
    public func $VERB_LOW_CASE(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.$VERB_LOW_CASE, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
EOF
done
echo "}" >> ${OUTPUT_FILE}
