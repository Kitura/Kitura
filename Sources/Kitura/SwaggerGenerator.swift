/*
 * Copyright IBM Corporation 2018
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
 */
import Foundation
import LoggerAPI
import KituraNet
import KituraContracts
import TypeDecoder

typealias QParams = OrderedDictionary<String, TypeInfo>

// Definition of document output formats.
enum SwaggerDocumentFormat {
    case json
    case yaml // not currently supported.
}

// Errors that can be thrown.
enum SwaggerGenerationError: Swift.Error {
    case invalidSwiftType
    case notImplemented
    case encodingError
}

// Container for Swagger response type.
struct SwaggerResponseType {
    var optional: Bool
    var array: Bool
    var type: String
}

// Container for Swagger document information.
struct SwaggerInfo: Encodable {
    var version: String
    var description: String
    var title: String
}

// Container for a reference.
struct SingleReference: Encodable {
    let ref: String

    enum CodingKeys: String, CodingKey {
        case ref = "$ref"
    }
}

// Container for an array of an internally referenced model. This is only used
// within responses.
// Note: By internally referenced, a reference in the definitions section of the
// Swagger document is inferred.
struct ArrayReference: Encodable {
    let type: String = "array"
    let items: SingleReference
}

// enum ResponseSchema describes all types of response:
// 1. An array of an internally referenced model
// 2. A single internally referenced model.
enum ResponseSchema: Encodable {
    case array(ArrayReference)
    case single(SingleReference)

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .array(let arrayRef): try container.encode(arrayRef)
        case .single(let singleRef): try container.encode(singleRef)
        }
    }
}

// enum CollectionFormat describes all types of array collections.
enum CollectionFormat: String, Encodable {
    case csv, ssv, tsv, pipes, multi

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

// struct BodyParameter: container for body parameter fields.
struct BodyParameter: Encodable {
    let invalue: String = "body"
    let name: String
    let required: Bool = true
    let schema: SingleReference?

    enum CodingKeys: String, CodingKey {
        case invalue = "in", name, required, schema
    }
}

// struct PathParameter: container for path parameter fields.
struct PathParameter: Encodable {
    let invalue: String = "path"
    let name: String
    let required: Bool = true
    let type: String

    enum CodingKeys: String, CodingKey {
        case invalue = "in", name, required, type
    }
}

// struct QueryParamArrayItems: container for query parameter array items fields.
struct QueryParamArrayItems: Encodable {
    let type: String
    let format: String?

    enum CodingKeys: String, CodingKey {
        case type, format
    }
}

// struct QueryParamArray: container for query parameter array fields.
struct QueryParamArray: Encodable {
    let invalue: String = "query"
    let name: String
    let required: Bool
    let type: String = "array"
    let items: QueryParamArrayItems
    let collectionFormat: CollectionFormat

    enum CodingKeys: String, CodingKey {
        case invalue = "in", name, required, type, items, collectionFormat
    }
}

// struct QueryParamArray: container for query parameter single fields.
struct QueryParamSingle: Encodable {
    let invalue: String = "query"
    let name: String
    let required: Bool
    let type: String
    let format: String?

    enum CodingKeys: String, CodingKey {
        case invalue = "in", name, required, type, format
    }
}

// struct QueryParamArray: container for query parameter fields.
enum QueryParameter: Encodable {
    case array(QueryParamArray)
    case single(QueryParamSingle)

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .array(let queryParamArray): try container.encode(queryParamArray)
        case .single(let queryParamSingle): try container.encode(queryParamSingle)
        }
    }
}

// Container for Swagger Parameters.
enum SwaggerParameter: Encodable {
    case body(BodyParameter)
    case path(PathParameter)
    case query(QueryParameter)

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .body(let bodyParameter): try container.encode(bodyParameter)
        case .path(let pathParameter): try container.encode(pathParameter)
        case .query(let queryParameter): try container.encode(queryParameter)
        }
    }
}

// Container for Swagger Response.
struct SwaggerResponse: Encodable {
    let description: String
    let schema: ResponseSchema?
}

// Container for Swagger Responses.
typealias SwaggerResponses = Dictionary<String, SwaggerResponse>

// Container for Swagger Method.
struct SwaggerMethod: Encodable {
    var consumes: [String]?
    var produces: [String]?
    var parameters: [SwaggerParameter]?
    var responses: SwaggerResponses
}

// Container for Swagger Methods.
typealias SwaggerMethods = Dictionary<String, SwaggerMethod>

// Container for array of native Swift types.
struct NativeArraySchema: Encodable {
    var type: String?
    var format: String?

    init(type: String) {
        self.type = type
        self.format = nil
    }

    init(type: String, format: String) {
        self.type = type
        self.format = format
    }
}

// enum PropertyValue describes all types of Property.
enum PropertyValue: Encodable {
    case arrayref(SingleReference)
    case nativearray(NativeArraySchema)
    case singleref(SingleReference)
    case string(String)
    case dict(SwaggerProperty)

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .arrayref(let reference): try container.encode(reference)
        case .singleref(let reference): try container.encode(reference)
        case .nativearray(let nativeArraySchema): try container.encode(nativeArraySchema)
        case .string(let stringValue): try container.encode(stringValue)
        case .dict(let dictSchema): try container.encode(dictSchema)
        }
    }
}

// Container for swagger Property.
typealias SwaggerProperty = Dictionary<String, PropertyValue>

// Container for swagger Properties.
typealias SwaggerProperties = OrderedDictionary<String, SwaggerProperty>

// Container for swagger Model.
struct SwaggerModel {
    var type: String
    var properties: SwaggerProperties
    var required: [String]
}

// Enum of supported Swift types.
// Note that there are ommissions here, notably Float80, because it is not codable.
enum SwiftType: String {
    case Bool
    case Dictionary
    case Double, Float, Float32, Float64
    case Int, UInt, Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64
    case String

    // Return the OpenApi (Swagger) type that maps to the Swift type.
    func swaggerType() -> String {
        switch self {
        case .Bool:
            return "boolean"
        case .Dictionary:
            return "object"
        case .Double, .Float, .Float32, .Float64:
            return "number"
        case .Int, .UInt, .Int8, .UInt8, .Int16, .UInt16, .Int32, .UInt32, .Int64, .UInt64:
            return "integer"
        case .String:
            return "string"
        }
    }

    // Return the OpenApi (Swagger) format needed for certain Swift types. Some
    // Swift types don't need a format, this is used to provide more info about
    // a type for an application that uses the generated Swagger doc.
    func swaggerFormat() -> String? {
        switch self {
        case .Float, .Float32, .Float64, .Int8, .UInt8, .Int16, .UInt16, .Int32, .UInt32, .Int64, .UInt64:
            return self.rawValue.lowercased()
        default:
            return nil
        }
    }

    // return true if name of type matches a Swift native type.
    static func isBaseType(_ typename: String) -> Bool {
        switch typename {
        case Bool.rawValue,
             Dictionary.rawValue,
             Double.rawValue,
             Float.rawValue,
             Float32.rawValue,
             Float64.rawValue,
             Int.rawValue,
             UInt.rawValue,
             Int8.rawValue,
             UInt8.rawValue,
             Int16.rawValue,
             UInt16.rawValue,
             Int32.rawValue,
             UInt32.rawValue,
             Int64.rawValue,
             UInt64.rawValue,
             String.rawValue:
            return true
        default:
            return false
        }
    }
}

struct SwaggerDocument: Encodable {
    // swagger document is the conatiner for all the openAPI information that we
    // can gather from the Kitura server. Once data is written to the structures
    // in SwaggerDocument, a call to toDocument() is used to write the document
    // to disk.
    private var swagger: String
    private var info: SwaggerInfo
    private var basePath: String
    private var schemes: [String]
    private var paths: Dictionary<String, SwaggerMethods>
    private var definitions: Dictionary<String, SwaggerModel>

    // processedSet & unprocessedSet are used for ensuring that models that are
    // only referenced from within another model are correctly processed.
    private var processedSet = Set<TypeInfo>()
    private var unprocessedSet = Set<TypeInfo>()

    // When encoding, only use these member vars as keys.
    private enum CodingKeys: String, CodingKey {
        case swagger, info, basePath, schemes, paths
    }

    public init() {
        self.swagger = "2.0"
        self.info = SwaggerInfo(version: "1.0", description: "Generated by Kitura", title: "Kitura Project")
        self.basePath = "/"
        self.schemes = [] // The valid schemes will be populated later, at serialisation time
        self.paths = [:]
        self.definitions = [:]
    }

    /// Gets a set of the types that have completed processing.
    public var processedTypes: Set<TypeInfo> { return processedSet }

    /// Gets a set of the types that have yet to be processed.
    public var unprocessedTypes: Set<TypeInfo> { return unprocessedSet }

    // Build a SwaggerParameter from a description and a parameter type.
    //
    // - Parameter name: A string name for the parameter.
    // - Parameter parametertype: A string representation of the parameter type.
    // - Returns: SwaggerParameter.
    func buildParameter(name: String, parameterType: String) -> SwaggerParameter {
        if name == "id" {
            // id can only be string or integer. so force the type to string if
            // it is neither.
            var idtype = "string"
            if let ptype = SwiftType(rawValue: parameterType) {
                idtype = ptype.swaggerType()
                if idtype != "integer" && idtype != "string" {
                    idtype = "string"
                }
            }

            let pParam = PathParameter(name: name, type: idtype)
            return SwaggerParameter.path(pParam)
        }
        let schema = SingleReference(ref: "#/definitions/\(parameterType)")
        let bParam = BodyParameter(name: name, schema: schema)
        return SwaggerParameter.body(bParam)
    }

    // Process a query parameter
    //
    // - Parameter name: The name of the parameter.
    // - Parameter typeInfo: The TypeInfo that represents this parameter.
    // - Parameter parameters: An array of parameters to append to.
    // - Parameter isArray: A boolean to indicate that this parameter is an array.
    // - Parameter isRequired: A boolean to indicate that this parameter is required.
    func processQueryParameter(name: String, typeInfo: TypeInfo, parameters: inout [SwaggerParameter], isArray array: Bool=false, isRequired required: Bool=true) {
        var property = [String: String]()
        var sp: SwaggerParameter

        if case .unkeyed(_, let elementTypeInfo) = typeInfo {
            // An array container.
            processQueryParameter(name: name, typeInfo: elementTypeInfo, parameters: &parameters, isArray: true, isRequired: required)
        } else if case .optional(let wrappedTypeInfo) = typeInfo {
            // An optional container.
            processQueryParameter(name: name, typeInfo: wrappedTypeInfo, parameters: &parameters, isArray: array, isRequired: false)
        } else if case .single(_, let typeInfo) = typeInfo {
            // A native type.
            if let swifttype = SwiftType(rawValue: String(describing: typeInfo)) {
                property["type"] = swifttype.swaggerType()
                if let format = swifttype.swaggerFormat() {
                    property["format"] = format
                }
                if let paramType = property["type"] {
                    if array {
                        let items = QueryParamArrayItems(type: paramType, format: property["format"])
                        let qpa = QueryParamArray(name: name, required: required, items: items, collectionFormat: CollectionFormat.csv)
                        sp = SwaggerParameter.query(QueryParameter.array(qpa))
                    } else {
                        let qps = QueryParamSingle(name: name, required: required, type: paramType, format: property["format"])
                        sp = SwaggerParameter.query(QueryParameter.single(qps))
                    }
                    parameters.append(sp)
                }
            }
        }
    }

    // Add query parameters.
    //
    // - Parameter qParams: A QueryParams object.
    // - Parameter parameters: An array of parameters to append to.
    func addQueryParameters(qParams: QParams, allOptQParams: Bool, parameters: inout [SwaggerParameter]) {
        for (name, typeInfo) in qParams {
            processQueryParameter(name: name, typeInfo: typeInfo, parameters: &parameters, isRequired: !allOptQParams)
        }
    }

    // Build a SwaggerResponse from a description and a response type.
    //
    // - Parameter description: A string description of the response.
    // - Parameter responseType: Either an array or a single response.
    // - Returns: SwaggerResponse.
    func buildResponse(description: String, responseType: SwaggerResponseType) -> SwaggerResponse {
        let reference = SingleReference(ref: "#/definitions/\(responseType.type)")
        if responseType.array {
            return SwaggerResponse(description: description, schema: .array(ArrayReference(items: reference)))
        }
        return SwaggerResponse(description: description, schema: .single(reference))
    }

    // Force-try is okay because we are compiling a known valid regex.
    // swiftlint:disable:next force_try
    private let tupleRegex = try! NSRegularExpression(pattern: "^\\(Optional\\(Swift\\.String\\), Optional\\(Swift\\.[a-zA-Z0-9]+\\)\\)$", options: [])


    // Determine if the type passed is a Dictionary.
    //
    // - Parameter _: Any swift type.
    // - Returns: Bool, True if the type passed in was originally a Swift dictionary.
    func isDictEncodedAsTuple(_ type: Any) -> Bool {
        let typeStr = "\(type)"
        let match = tupleRegex.matches(in: typeStr, options: [], range: NSRange(location: 0, length: typeStr.count))
        return match.count == 1
    }

    // Force-try is okay because we are compiling a known valid regex.
    // swiftlint:disable:next force_try
    private let unkeyedTypeRegex = try! NSRegularExpression(pattern: "^([^{\\]]+)", options: [])

    // Takes a type name for an unKeyed type (an Array) and strips the array
    // square brackets to give the type contained within the array.
    //
    // - Parameter _: A type name for a typedecoder unKeyed type (an array type).
    // - Returns: String name of the type contained within the array.
    func getUnkeyedTypeName(_ type: String) -> String {
        var arrayType = ""
        let nsType = NSString(string: type)
        let match = unkeyedTypeRegex.matches(in: type, options: [], range: NSRange(location: 0, length: type.count))
        if match.count > 0 {
            let arrayTypeRange = match[0].range(at: 1)
            arrayType = nsType.substring(with: arrayTypeRange) as String
        }
        return arrayType
    }

    // From a Swift type, return a SwaggerProperty.
    //
    // - Parameter _: Any swift type.
    // - Returns: SwaggerProperty.
    // - Throws: SwaggerGenerationError.invalidSwiftType.
    func swaggerPropertyFromSwiftType(_ theSwiftType: Any) throws -> SwaggerProperty {
        // return a property with the type and format.
        var property = SwaggerProperty()
        var swiftTypeStr = String(describing: theSwiftType)

        if isDictEncodedAsTuple(theSwiftType) {
            swiftTypeStr = "Dictionary"
        }

        if let type = SwiftType(rawValue: swiftTypeStr) {
            property["type"] = .string(type.swaggerType())
            if let format = type.swaggerFormat() {
                property["format"] = .string(format)
            }
        } else {
            throw SwaggerGenerationError.invalidSwiftType
        }
        return property
    }

    // From a TypeInfo, this function will return a SwaggerProperty object and an isOptional indicator.
    //
    // - Parameter _: TypeInfo for the type being decomposed.
    // - Parameter name: Name of the type being decomposed.
    // - Parameter isArray: indicate whether this is an array type.
    // - Parameter isOptional: indicate whether this is an optional type.
    // - Returns: Tuple containing  a SwaggerProperty that represents the type, and an optional flag.
    mutating func decomposeType(_ typeInfo: TypeInfo, name: String, isArray array: Bool=false, isRequired required: Bool=true) -> (SwaggerProperty, Bool) {
        var property = SwaggerProperty()

        switch typeInfo {
        case .keyed(let type, _):
            // found a keyed item, this is an embedded model that needs to be
            // turned into a separate definition and a ref to it placed here.
            addModel(model: typeInfo)
            let typeName = String(describing: type)
            property["$ref"] = .string("#/definitions/\(typeName)")
            return (property, required == true)
        case .dynamicKeyed(_, _ /*let keyTypeInfo*/, let valueTypeInfo):
            // found a Dictionary, this needs to be mapped to an "object" type with additionalProperties
            property["type"] = .string("object")
            let (prop, optional) = decomposeType(valueTypeInfo, name: name, isArray: array, isRequired: required)
            property["additionalProperties"] = .dict(prop)
            return (property, optional)
        case .unkeyed(_, let elementTypeInfo):
            // found an array.
            let typeName = self.getUnkeyedTypeName(String(describing: elementTypeInfo))
            if SwiftType.isBaseType(typeName) {
                if let type = SwiftType(rawValue: typeName) {
                    if let format = type.swaggerFormat() {
                        property["items"] = .nativearray(NativeArraySchema(type: type.swaggerType(), format: format))
                    } else {
                        property["items"] = .nativearray(NativeArraySchema(type: type.swaggerType()))
                    }
                }
            } else {
                property["items"] = .arrayref(SingleReference(ref: String(describing: "#/definitions/\(typeName)")))
            }
            property["type"] = .string("array")

            // check that this model has been processed, if not add it to the notProcessed set.
            if self.processedSet.contains(elementTypeInfo) == false {
                self.unprocessedSet.insert(elementTypeInfo)
            }
            return (property, required == true)
        case .cyclic(let type):
            property["type"] = .string(String(describing: type))
            return (property, required == true)
        case .single(_, let type):
            do {
                let property = try swaggerPropertyFromSwiftType(type)
                return (property, required == true)
            } catch {
                Log.warning("Failed to derive a SwaggerProperty from type '\(type)': \(error)")
            }
        case .optional(let wrappedTypeInfo):
            return decomposeType(wrappedTypeInfo, name: name, isArray: array, isRequired: false)
        case .opaque(let type):
            do {
                let property = try swaggerPropertyFromSwiftType(type)
                return (property, required == true)
            } catch {
                Log.warning("Failed to derive a SwaggerProperty from type '\(type)': \(error)")
            }
        }
        return (property, required)
    }

    // From a TypeInfo, this function will return a SwaggerProperty object and an isOptional indicator.
    //
    // - Parameter _: TypeInfo for the type being decomposed.
    // - Returns: Tuple containing a SwaggerProperties object that represents the model, and a Set of required fields.
    // - Throws: SwaggerGenerationError.invalidSwiftType.
    mutating func buildModel(_ typeInfo: TypeInfo?) throws -> (properties: SwaggerProperties, required: Set<String>) {
        var modelProperties = SwaggerProperties()
        var required = Set<String>()
        guard let typeInfo = typeInfo else {throw SwaggerGenerationError.invalidSwiftType }

        if case .keyed(_, let properties) = typeInfo {
            for (k, v) in properties {
                // Log.debug("found: key:\(k), value:\(v)")
                let (prop, reqd) = decomposeType(v, name: k)
                if reqd {
                    required.insert(k)
                }
                modelProperties[k] = prop
            }
            unprocessedSet.remove(typeInfo)
            processedSet.insert(typeInfo)
        } else {
            // This should not occur: addModel should only call buildModel for a keyed type
            Log.error("Expected a top-level (keyed) type, but received: \(typeInfo.debugDescription)")
        }
        return (modelProperties, required)
    }

    /// add a model into the OpenAPI (swagger) document
    ///
    /// - Parameter model: TypeInfo object that describes a model
    public mutating func addModel(model typeInfo: TypeInfo) {
        // from the typeinfo we can extract the model name and all subordinate structures.

        // get the model name.
        if case .keyed(let name, _) = typeInfo {
            let model = String(describing: name)
            var modelDefinition: SwaggerModel

            // Check to see if we have already built this model
            guard self.definitions[model] == nil else {
                Log.debug("Already generated model '\(model)'")
                return
            }

            // then build all it
            do {
                Log.verbose("Building model: '\(model)'")
                let modelInfo = try buildModel(typeInfo)
                if modelInfo.required.count > 0 {
                    modelDefinition = SwaggerModel(type: "object", properties: modelInfo.properties, required: Array(modelInfo.required))
                } else {
                    modelDefinition = SwaggerModel(type: "object", properties: modelInfo.properties, required: [])
                }
                self.definitions[model] = modelDefinition
            } catch {
                Log.warning("Failed to build model '\(model)': \(error)")
            }
        } else {
            Log.debug("Model not required for type '\(typeInfo.debugDescription)'")
        }
    }

    /// add a path into the OpenAPI (swagger) document
    ///
    /// - Parameter path: The API path to register.
    /// - Parameter method: The method the will be called on this path.
    /// - Parameter id: The name of the id parameter.
    /// - Parameter qParams: Query Parameters passed on the REST call.
    /// - Parameter optQParams: Whether all the query parameters in qParams are to be treated as optional.
    /// - Parameter responseList: An array of response types that can be returned from this path.
    public mutating func addPath(path: String, method: String, id: String?, qParams: QParams?, allOptQParams: Bool=false, inputType: String?, responseList: [SwaggerResponseType]?) {
        // split the path into its components:
        // - route path.
        // - parameters.

        let parts = path.components(separatedBy: ":")
        if parts.count > 0 {
            // build up the path structure.
            var swaggerPath = parts[0]

            // append an id parameter if needed.
            if id != nil {
                swaggerPath = swaggerPath.hasSuffix("/") ? swaggerPath + "{id}" : swaggerPath + "/{id}"
            }
            var responses = SwaggerResponses()
            if let responseTypes = responseList {
                if method == "delete" {
                    // special case for delete methods as they don't return codable objects, so a simple successful
                    // response statement is sufficient.
                    responses["200"] = SwaggerResponse(description: "successful response", schema: nil)
                } else {
                    responses["200"] = buildResponse(description: "successful response", responseType: responseTypes[0])
                }

                // handle the input parameter here: turn it into a parameters object.
                var parameters = [SwaggerParameter]()
                if let id = id {
                    parameters.append(buildParameter(name: "id", parameterType: id))
                }

                if let paramType = inputType {
                    parameters.append(buildParameter(name: "input", parameterType: paramType))
                }

                if let qParams = qParams {
                    // add any query parameters
                    addQueryParameters(qParams: qParams, allOptQParams: allOptQParams, parameters: &parameters)
                }

                // not going to use the default response for now as this refers to
                // ResponseError which is part of Kitura, so we would not want to
                // recreate it in the Models dir.
                // responses["default"] = buildResponse(description: "default response", responseType: responseList[1]).

                // build the method definition, note that parameters are optional.
                Log.verbose("Building method definition for '\(method)' on path '\(swaggerPath)'")
                let methodDefinition = SwaggerMethod(consumes: ["application/json"],
                                                     produces: ["application/json"],
                                                     parameters: parameters.count > 0 ? parameters : nil,
                                                     responses: responses)
                if var methods = self.paths[swaggerPath] {
                    // entry exists, so add the method.
                    Log.debug("Appending method definition to existing path '\(swaggerPath)'")

                    methods[method] = methodDefinition
                    self.paths[swaggerPath] = methods
                } else {
                    // no entry exists, so create one for this path.
                    Log.debug("Creating new methods definition for path '\(swaggerPath)'")

                    // first create a methods dict to hold all the methods for this path.
                    var methods = SwaggerMethods()
                    methods[method] = methodDefinition
                    self.paths[swaggerPath] = methods
                }
            }
        }
    }

    // JSON encode iall the properties (field name and type) for a model and return them
    // as a formatted String. The order of the properties is maintained.
    //
    // - Parameter properties: An ordered dictionary of properties.
    // - Parameter pretty: if true, the JSON will be formatted to be readable.
    // - Parameter depth: indentation depth for pretty formatting.
    func JSONEncodeModelProperties(properties: SwaggerProperties, pretty: Bool, depth: Int) throws -> String {
        var propertyStr = ""
        let sp = String(repeating: "  ", count: depth)
        let nl = pretty ? "\n" : ""

        let encoder = JSONEncoder()
        var fieldCount = 1
        for (field, fieldProps) in properties {
            propertyStr.append("\(sp)\"\(field)\": ")
            let encodedData = try encoder.encode(fieldProps)
            if let json = String(data: encodedData, encoding: .utf8) {
                propertyStr.append("\(json)")
                if fieldCount < properties.count {
                    propertyStr.append(",")
                }
                propertyStr.append("\(nl)")
                fieldCount += 1
            } else {
                Log.warning("Failed to generate utf8 String from JSON encoded data")
                throw SwaggerGenerationError.encodingError
            }
        }
        return propertyStr
    }

    // JSON encode the model content and return it as a formatted String. A
    // list of required fields is also encoded.
    //
    // - Parameter model: Name of the model being encoded.
    // - Parameter pretty: if true, the JSON will be formatted to be readable.
    // - Parameter depth: indentation depth for pretty formatting.
    func JSONEncodeModelContent(model: String, pretty: Bool, depth: Int) throws -> String {
        var contentStr = ""
        let sp = String(repeating: "  ", count: depth)
        let nl = pretty ? "\n" : ""

        if let modelRef = self.definitions[model] {
            contentStr.append("\(sp)\"type\": \"\(modelRef.type)\",\(nl)")
            if modelRef.required.count > 0 {
                let encoder = JSONEncoder()
                do {
                    let encodedData = try encoder.encode(modelRef.required)
                    if let json = String(data: encodedData, encoding: .utf8) {
                        contentStr.append("\(sp)\"required\": \(json),\(nl)")
                    } else {
                        throw SwaggerGenerationError.encodingError
                    }
                } catch let error as EncodingError {
                    Log.warning("Unable to encode required model references for model \(model): \(error)")
                    throw SwaggerGenerationError.encodingError
                }
            }
            contentStr.append("\(sp)\"properties\": {\(nl)")
            do {
                contentStr.append(try JSONEncodeModelProperties(properties: modelRef.properties, pretty: pretty, depth: depth + 1))
            } catch let error as EncodingError {
                Log.warning("Error encoding model properties for model \(model): \(error)")
                throw SwaggerGenerationError.encodingError
            }
            contentStr.append("\(sp)}\(nl)")
        } else {
            Log.warning("Model definition not found for \(model)")
            throw SwaggerGenerationError.encodingError
        }
        return contentStr
    }

    // JSON encode the model and return it as a formatted
    // String.
    //
    // - Parameter model: Name of the model being encoded.
    // - Parameter pretty: if true, the JSON will be formatted to be readable.
    // - Parameter depth: indentation depth for pretty formatting.
    func JSONEncodeModel(model: String, pretty: Bool, depth: Int) throws -> String {
        var modelStr = ""
        let sp = String(repeating: "  ", count: depth)
        let nl = pretty ? "\n" : ""

        let modelContent = try JSONEncodeModelContent(model: model, pretty: pretty, depth: depth + 1)
        modelStr.append("\(sp)\"\(model)\": {\(nl)")
        modelStr.append(modelContent)
        modelStr.append("\(sp)}")
        return modelStr
    }

    // JSON encode the definitions Dictionary and return it as a formatted
    // String. This is an order specific encoding to preserve the order of
    // the model fields in the definitions.
    //
    // - Parameter pretty: if true, the JSON will be formatted to be readable.
    func JSONEncodeDefinitions(pretty: Bool) throws -> String {
        var depth = 0
        var nl = ""
        var definitionsStr = ""

        if pretty {
            depth = 1
            nl = "\n"
        }

        let sp = String(repeating: "  ", count: depth)

        definitionsStr = ",\(nl)"
        definitionsStr.append("\(sp)\"definitions\": {\(nl)")
        var modelCount = 0
        for model in self.definitions.keys {
            modelCount += 1
            let encodedModel = try JSONEncodeModel(model: model, pretty: pretty, depth: depth + 1)
            definitionsStr.append(encodedModel)
            if modelCount < definitions.count {
                definitionsStr.append(",")
            }
            definitionsStr.append("\(nl)")
        }

        definitionsStr.append("\(sp)}\(nl)")
        definitionsStr.append("}")
        return definitionsStr
    }

    /// Convert this object into a JSON formatted string.
    ///
    public func serializeAPIToJSON() throws -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let encodedData = try encoder.encode(self)
        var search = "}"
        var json = String(data: encodedData, encoding: .utf8)
        if var unwrappedJson = json {
            if encoder.outputFormatting == .prettyPrinted {
                search = "\n}"
            }
            if let insertionIndex = unwrappedJson.range(of: search, options: .backwards)?.lowerBound {
                let definitions = try JSONEncodeDefinitions(pretty: encoder.outputFormatting == .prettyPrinted)
                unwrappedJson.replaceSubrange(insertionIndex..., with: definitions)
            }
            json = unwrappedJson
        }
        return json
    }

    /// Convert this object into a serialized document.
    ///
    /// - Parameter format: The serialization format of the document.
    mutating public func serializeAPI(format: SwaggerDocumentFormat) throws -> String? {
        var document: String?

        Kitura.serverLock.lock()
        self.schemes = []
        if !Kitura.httpServersAndPorts.filter({ $0.server.sslConfig == nil }).isEmpty {
            self.schemes.append("http")
        }
        if !Kitura.httpServersAndPorts.filter({ $0.server.sslConfig != nil }).isEmpty {
            self.schemes.append("https")
        }
        Kitura.serverLock.unlock()

        switch format {
        case .json:
            document = try serializeAPIToJSON()

        case .yaml:
            throw SwaggerGenerationError.notImplemented
        }
        return document
    }
}

extension Router {

    // Describes the type of a parameter in a log message
    private enum ParamType: String {
        case outputType = "Output"
        case inputType = "Input"
        case queryParamType = "Query parameters"
    }

    // Log information about the circumstances of a TypeDecodeError
    private func logTypeDecodeError<T: Codable>(_ error: Swift.Error, for type: T.Type, on route: String, as param: ParamType) {
        if let error = error as? TypeDecodingError {
            var underlyingErrorString = ""
            if let underlyingError = error.context.underlyingError {
                underlyingErrorString = "Underlying error: \(underlyingError)"
            }
            Log.warning("\(param.rawValue) type `\(type)` on path `\(route)` could not be decoded: \(error.context.debugDescription) \(underlyingErrorString)")
        } else {
            Log.warning("\(param.rawValue) type `\(type)` on path `\(route)` could not be decoded: \(error)")
        }
    }

    // Register a route in the SwaggerDocument.
    //
    // - Parameter route: The route to be registered.
    // - Parameter method: The http method name: one of 'get', 'patch', 'post', 'put'.
    // - Parameter outputType: The type of the model to register.
    // - Parameter responseTypes: array of expected swagger response type objects.
    func registerRoute<O: Codable>(route: String, method: String, outputType: O.Type, responseTypes: [SwaggerResponseType]) {
        Log.debug("Registering \(route) for \(method) method")

        let typeInfo: TypeInfo
        do {
            typeInfo = try TypeDecoder.decode(outputType)
        } catch {
            return logTypeDecodeError(error, for: outputType, on: route, as: .outputType)
        }

        // insert the path information into the document structure.
        swagger.addPath(path: route, method: method, id: nil, qParams: nil, inputType: nil, responseList: responseTypes)

        // add model information into the document structure.
        swagger.addModel(model: typeInfo)

        // now walk all the unprocessed models and ensure they are processed.
        for unprocessed in Array(swagger.unprocessedTypes) {
            Log.debug("Processing unprocessed model: \(unprocessed.debugDescription)")
            swagger.addModel(model: unprocessed)
        }
    }

    // Register a route in the SwaggerDocument.
    //
    // - Parameter route: The route to be registered.
    // - Parameter method: The http method name: one of 'get', 'patch', 'post', 'put'.
    // - Parameter queryTypes: The types of the query parameters.
    // - Parameter allOptQParams: The type of the model to register.
    // - Parameter outputType: The type of the model to register.
    // - Parameter responseTypes: array of expected swagger response type objects.
    func registerRoute<Q: QueryParams, O: Codable>(route: String, method: String, queryType: Q.Type, allOptQParams: Bool, outputType: O.Type, responseTypes: [SwaggerResponseType]) {
        Log.debug("Registering \(route) for \(method) method")

        let typeInfo: TypeInfo
        do {
            typeInfo = try TypeDecoder.decode(outputType)
        } catch {
            return logTypeDecodeError(error, for: outputType, on: route, as: .outputType)
        }

        var params: OrderedDictionary<String, TypeInfo>? = nil
        do {
            if case .keyed(_, let dict) = try TypeDecoder.decode(queryType) {
                params = dict
            }
        } catch {
            return logTypeDecodeError(error, for: queryType, on: route, as: .queryParamType)
        }

        // insert the path information into the document structure.
        swagger.addPath(path: route, method: method, id: nil, qParams: params, allOptQParams: allOptQParams, inputType: nil, responseList: responseTypes)

        // add model information into the document structure.
        swagger.addModel(model: typeInfo)

        // now walk all the unprocessed models and ensure they are processed.
        for unprocessed in Array(swagger.unprocessedTypes) {
            Log.debug("Processing unprocessed model: \(unprocessed.debugDescription)")
            swagger.addModel(model: unprocessed)
        }
    }

    // Register a route in the SwaggerDocument.
    //
    // - Parameter route: The route to be registered.
    // - Parameter method: The http method name: one of 'get', 'patch', 'post', 'put'.
    // - Parameter inputType: The type of the model to register.
    // - Parameter outputType: The type of the model to register.
    // - Parameter responseTypes: array of expected swagger response type objects.
    func registerRoute<I: Codable, O: Codable>(route: String, method: String, inputType: I.Type, outputType: O.Type, responseTypes: [SwaggerResponseType]) {
        Log.debug("Registering \(route) for \(method) method")

        let inputTypeInfo: TypeInfo
        do {
            inputTypeInfo = try TypeDecoder.decode(inputType)
        } catch {
            return logTypeDecodeError(error, for: inputType, on: route, as: .inputType)
        }

        var outputTypeInfo: TypeInfo? = nil
        if inputType != outputType {
            do {
                outputTypeInfo = try TypeDecoder.decode(outputType)
            } catch {
                return logTypeDecodeError(error, for: outputType, on: route, as: .outputType)
            }
        }

        // insert the path information into the document structure.
        swagger.addPath(path: route, method: method, id: nil, qParams: nil, inputType: "\(inputType)", responseList: responseTypes)

        // add model information into the document structure.
        swagger.addModel(model: inputTypeInfo)
        if let outputTypeInfo = outputTypeInfo {
            swagger.addModel(model: outputTypeInfo)
        }

        // now walk all the unprocessed models and ensure they are processed.
        for unprocessed in Array(swagger.unprocessedTypes) {
            Log.debug("Processing unprocessed model: \(unprocessed.debugDescription)")
            swagger.addModel(model: unprocessed)
        }
    }

    // Register a route in the SwaggerDocument.
    //
    // - Parameter route: The route to be registered.
    // - Parameter method: The http method name: one of 'get', 'patch', 'post', 'put'.
    // - Parameter id: The type of the identifier.
    // - Parameter outputType: The type of the model to register.
    // - Parameter responseTypes: array of expected swagger response type objects.
    func registerRoute<Id: Identifier, O: Codable>(route: String, method: String, id: Id.Type, outputType: O.Type, responseTypes: [SwaggerResponseType]) {
        Log.debug("Registering \(route) for \(method) method")

        let typeInfo: TypeInfo
        do {
            typeInfo = try TypeDecoder.decode(outputType)
        } catch {
            return logTypeDecodeError(error, for: outputType, on: route, as: .outputType)
        }

        // insert the path information into the document structure.
        swagger.addPath(path: route, method: method, id: "\(id)", qParams: nil, inputType: nil, responseList: responseTypes)

        // add model information into the document structure.
        swagger.addModel(model: typeInfo)

        // now walk all the unprocessed models and ensure they are processed.
        for unprocessed in Array(swagger.unprocessedTypes) {
            Log.debug("Processing unprocessed model: \(unprocessed.debugDescription)")
            swagger.addModel(model: unprocessed)
        }
    }

    // Register a route in the SwaggerDocument.
    //
    // - Parameter route: The route to be registered.
    // - Parameter method: The http method name: one of 'get', 'patch', 'post', 'put'.
    // - Parameter id: The type of the identifier.
    // - Parameter inputType: The type of the input model to register.
    // - Parameter outputType: The type of the output model to register.
    // - Parameter responseTypes: array of expected swagger response type objects.
    func registerRoute<Id: Identifier, I: Codable, O: Codable>(route: String, method: String, id: Id.Type, inputType: I.Type, outputType: O.Type, responseTypes: [SwaggerResponseType]) {
        Log.debug("Registering \(route) for \(method) method")

        let inputTypeInfo: TypeInfo
        do {
            inputTypeInfo = try TypeDecoder.decode(inputType)
        } catch {
            return logTypeDecodeError(error, for: inputType, on: route, as: .inputType)
        }

        var outputTypeInfo: TypeInfo? = nil
        if inputType != outputType {
            do {
                outputTypeInfo = try TypeDecoder.decode(outputType)
            } catch {
                return logTypeDecodeError(error, for: outputType, on: route, as: .outputType)
            }
        }

        // insert the path information into the document structure
        swagger.addPath(path: route, method: method, id: "\(id)", qParams: nil, inputType: "\(inputType)", responseList: responseTypes)

        // add model information into the document structure.
        swagger.addModel(model: inputTypeInfo)
        if let outputTypeInfo = outputTypeInfo {
            swagger.addModel(model: outputTypeInfo)
        }

        // now walk all the unprocessed models and ensure they are processed.
        for unprocessed in Array(swagger.unprocessedTypes) {
            Log.debug("Processing unprocessed model: \(unprocessed.debugDescription)")
            swagger.addModel(model: unprocessed)
        }
    }

    // Register a delete route in the SwaggerDocument.
    //
    // - Parameter route: The route to be registered.
    // - Parameter responseTypes: array of expected swagger response type objects.
    func registerDelete(route: String, responseTypes: [SwaggerResponseType]) {
        Log.debug("Registering \(route) for delete method")

        // insert the path information into the document structure.
        swagger.addPath(path: route, method: "delete", id: nil, qParams: nil, inputType: nil, responseList: responseTypes)
    }

    // Register a delete route in the SwaggerDocument.
    //
    // - Parameter route: The route to be registered.
    // - Parameter queryType: The type of any query parameters.
    // - Parameter allOptQParams: Flag to indicate that the parameters are optional.
    // - Parameter responseTypes: array of expected swagger response type objects.
    func registerDelete<Q: QueryParams>(route: String, queryType: Q.Type, allOptQParams: Bool, responseTypes: [SwaggerResponseType]) {
        Log.debug("Registering \(route) for delete method")

        let typeInfo: TypeInfo
        var params: OrderedDictionary<String, TypeInfo>? = nil
        do {
            typeInfo = try TypeDecoder.decode(queryType)
            if case .keyed(_, let dict) = typeInfo {
                params = dict
            }
        } catch {
            return logTypeDecodeError(error, for: queryType, on: route, as: .queryParamType)
        }

        // insert the path information into the document structure.
        swagger.addPath(path: route, method: "delete", id: nil, qParams: params, allOptQParams: allOptQParams, inputType: nil, responseList: responseTypes)
    }

    // Register a delete route in the SwaggerDocument.
    //
    // - Parameter route: The route to be registered.
    // - Parameter id: The type of the identifier.
    func registerDelete<Id: Identifier>(route: String, id: Id.Type, responseTypes: [SwaggerResponseType]) {
        Log.debug("Registering \(route) for delete method")

        // insert the path information into the document structure.
        swagger.addPath(path: route, method: "delete", id: "\(id)", qParams: nil, inputType: nil, responseList: responseTypes)
    }

    /// Register GET route
    ///
    /// - Parameter route: The route to register.
    /// - Parameter outputtype: The output object type.
    public func registerGetRoute<O: Codable>(route: String, outputType: O.Type, outputIsArray: Bool = false) {
        var responseTypes = [SwaggerResponseType]()
        responseTypes.append(SwaggerResponseType(optional: true, array: outputIsArray, type: "\(O.self)"))
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: "RequestError"))
        registerRoute(route: route, method: "get", outputType: O.self, responseTypes: responseTypes)
    }

    /// Register GET route
    ///
    /// - Parameter route: The route to register.
    /// - Parameter id: The id type.
    /// - Parameter outputtype: The output object type.
    public func registerGetRoute<Id: Identifier, O: Codable>(route: String, id: Id.Type, outputType: O.Type, outputIsArray: Bool = false) {
        var responseTypes = [SwaggerResponseType]()
        responseTypes.append(SwaggerResponseType(optional: true, array: outputIsArray, type: "\(O.self)"))
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: "RequestError"))
        registerRoute(route: route, method: "get", id: Id.self, outputType: O.self, responseTypes: responseTypes)
    }

    /// Register GET route
    ///
    /// - Parameter route: The route to register.
    /// - Parameter queryParams: The query parameters.
    /// - Parameter optionalQParam: Flag to indicate that the query params are all optional.
    /// - Parameter outputType: The output object type.
    public func registerGetRoute<Q: QueryParams, O: Codable>(route: String, queryParams: Q.Type, optionalQParam: Bool, outputType: O.Type, outputIsArray: Bool = false) {
        var responseTypes = [SwaggerResponseType]()
        responseTypes.append(SwaggerResponseType(optional: true, array: outputIsArray, type: "\(O.self)"))
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: "RequestError"))
        registerRoute(route: route, method: "get", queryType: Q.self, allOptQParams: optionalQParam, outputType: O.self, responseTypes: responseTypes)
    }

    /// Register DELETE route
    ///
    /// - Parameter route: The route to register.
    public func registerDeleteRoute(route: String) {
        var responseTypes = [SwaggerResponseType]()
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: ""))
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: "RequestError"))
        registerDelete(route: route, responseTypes: responseTypes)
    }

    /// Register DELETE route
    ///
    /// - Parameter route: The route to register.
    /// - Parameter queryParams: The query parameters.
    /// - Parameter optionalQParam: Flag to indicate that the query params are all optional.
    public func registerDeleteRoute<Q: QueryParams>(route: String, queryParams: Q.Type, optionalQParam: Bool) {
        var responseTypes = [SwaggerResponseType]()
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: ""))
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: "RequestError"))
        registerDelete(route: route, queryType: Q.self, allOptQParams: optionalQParam, responseTypes: responseTypes)
    }

    /// Register DELETE route
    ///
    /// - Parameter route: The route to register.
    /// - Parameter id: The id type.
    public func registerDeleteRoute<Id: Identifier>(route: String, id: Id.Type ) {
        var responseTypes = [SwaggerResponseType]()
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: ""))
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: "RequestError"))
        registerDelete(route: route, id: Id.self, responseTypes: responseTypes)
    }

    /// Register POST route that is handled by a CodableIdentifierClosure.
    ///
    /// - Parameter route: The route to register.
    /// - Parameter inputType: The input object type.
    /// - Parameter outputType: The output object type.
    public func registerPostRoute<I: Codable, O: Codable>(route: String, inputType: I.Type, outputType: O.Type) {
        var responseTypes = [SwaggerResponseType]()
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: "\(O.self)"))
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: "RequestError"))
        registerRoute(route: route, method: "post", inputType: I.self, outputType: O.self, responseTypes: responseTypes)
    }

    /// Register POST route that is handled by a CodableIdentifierClosure.
    ///
    /// - Parameter route: The route to register.
    /// - Parameter id: The id type.
    /// - Parameter inputType: The input object type.
    /// - Parameter outputType: The output object type.
    public func registerPostRoute<I: Codable, Id: Identifier, O: Codable>(route: String, id: Id.Type, inputType: I.Type, outputType: O.Type) {
        var responseTypes = [SwaggerResponseType]()
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: "\(O.self)"))
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: "RequestError"))
        registerRoute(route: route, method: "post", id: Id.self, inputType: I.self, outputType: O.self, responseTypes: responseTypes)
    }

    /// Register PUT route that is handled by a IdentifierCodableClosure.
    ///
    /// - Parameter route: The route to register.
    /// - Parameter id: The id type.
    /// - Parameter inputType: The input object type.
    /// - Parameter outputType: The output object type.
    public func registerPutRoute<Id: Identifier, I: Codable, O: Codable>(route: String, id: Id.Type, inputType: I.Type, outputType: O.Type) {
        var responseTypes = [SwaggerResponseType]()
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: "\(O.self)"))
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: "RequestError"))
        registerRoute(route: route, method: "put", id: Id.self, inputType: I.self, outputType: O.self, responseTypes: responseTypes)
    }

    /// Register PATCH route that is handled by an IdentifierCodableClosure.
    ///
    /// - Parameter route: The route to register.
    /// - Parameter id: The id type.
    /// - Parameter inputType: The input object type.
    /// - Parameter outputType: The output object type.
    public func registerPatchRoute<Id: Identifier, I: Codable, O: Codable>(route: String, id: Id.Type, inputType: I.Type, outputType: O.Type) {
        var responseTypes = [SwaggerResponseType]()
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: "\(O.self)"))
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: "RequestError"))
        registerRoute(route: route, method: "patch", id: Id.self, inputType: I.self, outputType: O.self, responseTypes: responseTypes)
    }
}
