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
import KituraNIO
import KituraContracts
import TypeDecoder

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

typealias SwaggerRef = String

// Container for a single reference.
struct SingleRefSchema: Encodable {
    let ref: SwaggerRef

    enum CodingKeys: String, CodingKey {
        case ref = "$ref"
    }
}

// Container for an array reference.
struct ArrayRefItems: Encodable {
    let ref: SwaggerRef

    enum CodingKeys: String, CodingKey {
        case ref = "$ref"
    }
}

// Container for an array of an internally referenced model. This is only used
// within responses.
// Note: By internally referenced, a reference in the definitions section of the
// Swagger document is inferred.
struct ArrayRefSchema: Encodable {
    let type: String
    let items: ArrayRefItems
}

// enum ResponseSchema describes all types of response:
// 1. An array of an internally referenced model
// 2. A single internally referenced model.
enum ResponseSchema: Encodable {
    case array(ArrayRefSchema)
    case single(SingleRefSchema)

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .array(let arrayRefSchema): try container.encode(arrayRefSchema)
        case .single(let singleRefSchema): try container.encode(singleRefSchema)
        }
    }
}

// Container for Swagger Parameters.
struct SwaggerParameter: Encodable {
    let invalue: String
    let name: String
    let required: Bool
    let schema: SingleRefSchema?
    let type: String?

    enum CodingKeys: String, CodingKey {
        case invalue = "in", name, required, schema, type
    }
}

// Container for Swagger Response.
struct SwaggerResponse: Encodable {
    let description: String
    let schema: ResponseSchema?
}

// Container for Swagger Parameters.
typealias SwaggerParameters = [SwaggerParameter]

// Container for Swagger Responses.
typealias SwaggerResponses = Dictionary<String, SwaggerResponse>

// Container for Swagger Method.
struct SwaggerMethod: Encodable {
    var consumes: [String]
    var produces: [String]
    var parameters: SwaggerParameters
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
    case arrayref(ArrayRefItems)
    case nativearray(NativeArraySchema)
    case singleref(SingleRefSchema)
    case string(String)
    case dict(SwaggerProperty)

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .arrayref(let arrayRefItems): try container.encode(arrayRefItems)
        case .singleref(let singleRefSchema): try container.encode(singleRefSchema)
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
    case Double
    case Float
    case Float32
    case Float64
    case Int
    case UInt
    case Int8
    case UInt8
    case Int16
    case UInt16
    case Int32
    case UInt32
    case Int64
    case UInt64
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
        case .Float:
            return "float"
        case .Float32:
            return "float32"
        case .Float64:
            return "float64"
        case .Int8:
            return "int8"
        case .UInt8:
            return "uint8"
        case .Int16:
            return "int16"
        case .UInt16:
            return "uint16"
        case .Int32:
            return "int32"
        case .UInt32:
            return "uint32"
        case .Int64:
            return "int64"
        case .UInt64:
            return "uint64"
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
        self.schemes = ["http", "https"] // for now, both schemes hard-coded.
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
    func buildParameter(name: String, parametertype: String) -> SwaggerParameter {
        if name == "id" {
            return SwaggerParameter(invalue: "path",
                                    name: name,
                                    required: true,
                                    schema: nil,
                                    type: "integer")
        }
        return SwaggerParameter(invalue: "body",
                                name: name,
                                required: true,
                                schema: SingleRefSchema(ref: "#/definitions/\(parametertype)"),
                                type: nil)
    }

    // Build a SwaggerResponse from a description and a response type.
    //
    // - Parameter description: A string description of the response.
    // - Parameter responsetype: Either an array or a single response.
    // - Returns: SwaggerResponse.
    func buildResponse(description: String, responsetype: SwaggerResponseType) -> SwaggerResponse {
        if responsetype.array {
            return SwaggerResponse(description: description,
                                   schema: .array(ArrayRefSchema(type: "array",
                                                                 items: ArrayRefItems(ref: "#/definitions/\(responsetype.type)"))))
        }
        return SwaggerResponse(description: description,
                               schema: .single(SingleRefSchema(ref: "#/definitions/\(responsetype.type)")))
    }

    // Determine if the type passed is a Dictionary.
    //
    // - Parameter _: Any swift type.
    // - Returns: Bool, True if the type passed in was originally a Swift dictionary.
    func isDictEncodedAsTuple(_ type: Any) -> Bool {
        let typeStr = "\(type)"
        let pattern = "^\\(Optional\\(Swift\\.String\\), Optional\\(Swift\\.[a-zA-Z0-9]+\\)\\)$"
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let match = regex.matches(in: typeStr, options: [], range: NSRange(location: 0, length: typeStr.count))
            return match.count == 1
        }
        return false
    }

    // Takes a type name for an unKeyed type (an Array) and strips the array
    // square brackets to give the type contained within the array.
    //
    // - Parameter _: A type name for a typedecoder unKeyed type (an array type).
    // - Returns: String name of the type contained within the array.
    func getUnkeyedTypeName(_ type: String) -> String {
        var arrayType = ""
        let nsType = NSString(string: type)
        let pattern = "^([^{\\]]+)"
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let match = regex.matches(in: type, options: [], range: NSRange(location: 0, length: type.count))
            if match.count > 0 {
                let arrayTypeRange = match[0].range(at: 1)
                arrayType = nsType.substring(with: arrayTypeRange) as String
            }
        }
        return arrayType
    }

    // From a Swift type, return a SwaggerProperty.
    //
    // - Parameter _: Any swift type.
    // - Returns: SwaggerProperty.
    // - Throws: SwaggerGenerationError.invalidSwiftType.
    func swaggerPropertyFromSwiftType(_ swifttype: Any) throws -> SwaggerProperty {
        // return a property with the type and format.
        var property = SwaggerProperty()
        var swiftTypeStr = String(describing: swifttype)

        if isDictEncodedAsTuple(swifttype) {
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
    mutating func decomposeType(_ t: TypeInfo, name: String, isArray: Bool=false, isOptional: Bool=false) -> (SwaggerProperty, Bool) {
        var property = SwaggerProperty()
        let required = false

        switch t {
        case .keyed(let type, _):
            // found a keyed item, this is an embedded model that needs to be
            // turned into a separate definition and a ref to it placed here.
            add(model: t)
            let typeName = String(describing: type)
            property["$ref"] = .string("#/definitions/\(typeName)")
            return (property, isOptional == false)
        case .dynamicKeyed(_, _ /*let keyTypeInfo*/, let valueTypeInfo):
            // found a Dictionary, this needs to be mapped to an "object" type with additionalProperties
            property["type"] = .string("object")
            let (prop, optional) = decomposeType(valueTypeInfo, name: name, isArray: isArray, isOptional: isOptional)
            property["additionalProperties"] = .dict(prop)
            return (property, optional)
        case .unkeyed(_, let elementTypeInfo):
            // found an array.
            let typeinfo = String(describing: elementTypeInfo)
            let typeName = self.getUnkeyedTypeName(typeinfo)
            if SwiftType.isBaseType(typeName) {
                if let type = SwiftType(rawValue: typeName) {
                    if let format = type.swaggerFormat() {
                        property["items"] = .nativearray(NativeArraySchema(type: type.swaggerType(), format: format))
                    } else {
                        property["items"] = .nativearray(NativeArraySchema(type: type.swaggerType()))
                    }
                }
            } else {
                property["items"] = .arrayref(ArrayRefItems(ref: String(describing: "#/definitions/\(typeName)")))
            }
            property["type"] = .string("array")

            // check that this model has been processed, if not add it to the notProcessed set.
            if self.processedSet.contains(elementTypeInfo) == false {
                self.unprocessedSet.insert(elementTypeInfo)
            }
            return (property, isOptional == false)
        case .cyclic(let type):
            property["type"] = .string(String(describing: type))
            return (property, isOptional == false)
        case .single(_, let type):
            if let property = try? swaggerPropertyFromSwiftType(type) {
                return (property, isOptional == false)
            }
        case .optional(let wrappedTypeInfo):
            return decomposeType(wrappedTypeInfo, name: name, isArray: isArray, isOptional: true)
        case .opaque(let type):
            if let property = try? swaggerPropertyFromSwiftType(type) {
                return (property, isOptional == false)
            }
        }
        return (property, required)
    }

    // From a TypeInfo, this function will return a SwaggerProperty object and an isOptional indicator.
    //
    // - Parameter _: TypeInfo for the type being decomposed.
    // - Returns: Tuple containing a SwaggerProperties object that represents the model, and a Set of required fields.
    // - Throws: SwaggerGenerationError.invalidSwiftType.
    mutating func buildModel(_ t: TypeInfo?) throws -> (properties: SwaggerProperties, required: Set<String>) {
        var modelProperties = SwaggerProperties()
        var required = Set<String>()
        guard let t = t else {throw SwaggerGenerationError.invalidSwiftType }

        if case .keyed(_, let properties) = t {
            for (k, v) in properties {
                Log.debug("found: key:\(k), value:\(v)")
                let (prop, reqd) = decomposeType(v, name: k)
                if reqd {
                    required.insert(k)
                }
                modelProperties[k] = prop
            }
            unprocessedSet.remove(t)
            processedSet.insert(t)
        }
        return (modelProperties, required)
    }

    /// add a model into the OpenAPI (swagger) document
    ///
    /// - Parameter model: TypeInfo object that describes a model
    public mutating func add(model typeinfo: TypeInfo) {
        // from the typeinfo we can extract the model name and all subordinate structures.

        // get the model name.
        if case let .keyed(o, _) = typeinfo {
            let model = String(describing: o)
            var modelDefinition: SwaggerModel

            // then build all it
            if let modelInfo = try? buildModel(typeinfo) {
                Log.debug("in add(model: \(model))")
                if modelInfo.required.count > 0 {
                    modelDefinition = SwaggerModel(type: "object", properties: modelInfo.properties, required: Array(modelInfo.required))
                } else {
                    modelDefinition = SwaggerModel(type: "object", properties: modelInfo.properties, required: [])
                }
                self.definitions[model] = modelDefinition
            }
        }
    }

    /// add a path into the OpenAPI (swagger) document
    ///
    /// - Parameter path: The API path to register.
    /// - Parameter method: The method the will be called on this path.
    /// - Parameter responselist: An array of response types that can be returned from this path.
    public mutating func add(path: String, method: String, id: Bool, inputtype: String?, responselist: [SwaggerResponseType]?) {
        Log.debug("in add(path: \(path))")
        // split the path into its components:
        // - route path.
        // - parameters.

        let parts = path.components(separatedBy: ":")
        if parts.count > 0 {
            // build up the path structure.
            var swaggerPath = parts[0]

            // append an id parameter if needed.
            if id {
                swaggerPath = swaggerPath.hasSuffix("/") ? swaggerPath + "{id}" : swaggerPath + "/{id}"
            }
            var responses = SwaggerResponses()
            if let responsetypes = responselist {
                if method == "delete" {
                    // special case for delete methods as they don't return codable objects, so a simple successful
                    // response statement is sufficient.
                    responses["200"] = SwaggerResponse(description: "successful response", schema: nil)
                } else {
                    responses["200"] = buildResponse(description: "successful response", responsetype: responsetypes[0])
                }

                // handle the input parameter here: turn it into a parameters object.
                var parameters = SwaggerParameters()
                if id {
                    parameters.append(buildParameter(name: "id", parametertype: "int"))
                }

                if let paramtype = inputtype {
                    parameters.append(buildParameter(name: "input", parametertype: paramtype))
                }

                // not going to use the default response for now as this refers to
                // ResponseError which is part of Kitura, so we would not want to
                // recreate it in the Models dir.
                // responses["default"] = buildResponse(description: "default response", responsetype: responselist[1]).

                let methodDefinition = SwaggerMethod(consumes: ["application/json"],
                                                     produces: ["application/json"],
                                                     parameters: parameters,
                                                     responses: responses)
                if var methods = self.paths[swaggerPath] {
                    // entry exists, so add the method.
                    Log.debug("found swagger methods definition for path \"\(swaggerPath)\"")

                    methods[method] = methodDefinition
                    self.paths[swaggerPath] = methods
                } else {
                    // no entry exists, so create one for this path.
                    Log.debug("no swagger method definition for \"\(method)\" on path \"\(swaggerPath)\", creating one")

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
            do {
                let encodedData = try encoder.encode(fieldProps)
                if let json = String(data: encodedData, encoding: .utf8) {
                    propertyStr.append("\(json)")
                    if fieldCount < properties.count {
                        propertyStr.append(",")
                    }
                    propertyStr.append("\(nl)")
                    fieldCount += 1
                } else {
                    throw SwaggerGenerationError.encodingError
                }
            } catch {
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

        do {
            if let modelRef = self.definitions[model] {
                contentStr.append("\(sp)\"type\": \"\(modelRef.type)\",\(nl)")
                if modelRef.required.count > 0 {
                    let encoder = JSONEncoder()
                    let encodedData = try encoder.encode(modelRef.required)
                    if let json = String(data: encodedData, encoding: .utf8) {
                        contentStr.append("\(sp)\"required\": \(json),\(nl)")
                    } else {
                        throw SwaggerGenerationError.encodingError
                    }
                }
                contentStr.append("\(sp)\"properties\": {\(nl)")
                contentStr.append(try JSONEncodeModelProperties(properties: modelRef.properties, pretty: pretty, depth: depth + 1))
                contentStr.append("\(sp)}\(nl)")
            } else {
                throw SwaggerGenerationError.encodingError
            }
        } catch {
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

        if let modelContent = try? JSONEncodeModelContent(model: model, pretty: pretty, depth: depth + 1) {
            modelStr.append("\(sp)\"\(model)\": {\(nl)")
            modelStr.append(modelContent)
            modelStr.append("\(sp)}")
        } else {
            throw SwaggerGenerationError.encodingError
        }
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
            if let encodedModel = try? JSONEncodeModel(model: model, pretty: pretty, depth: depth + 1) {
                definitionsStr.append(encodedModel)
                if modelCount < definitions.count {
                    definitionsStr.append(",")
                }
                definitionsStr.append("\(nl)")
            } else {
                throw SwaggerGenerationError.encodingError
            }
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
                if let definitions = try? JSONEncodeDefinitions(pretty: encoder.outputFormatting == .prettyPrinted) {
                    unwrappedJson.replaceSubrange(insertionIndex..., with: definitions)
                } else {
                    throw SwaggerGenerationError.encodingError
                }
            }
            json = unwrappedJson
        }
        return json
    }

    /// Convert this object into a serialized document.
    ///
    /// - Parameter format: The serialization format of the document.
    public func serializeAPI(format: SwaggerDocumentFormat) throws -> String? {
        var document: String?

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
    // Register a route in the SwaggerDocument.
    //
    // - Parameter route: The route to be registered.
    // - Parameter method: The http method name: one of 'get', 'patch', 'post', 'put'.
    // - Parameter id: Boolean indicator whether id is used.
    // - Parameter outputtype: The type of the model to register.
    // - Parameter responsetypes: array of expected swagger response type objects.
    func registerRoute<O: Codable>(route: String, method: String, id: Bool, outputtype: O.Type, responsetypes: [SwaggerResponseType]) {
        Log.debug("Registering \(route) for \(method) method")

        let t: TypeInfo
        do {
            t = try TypeDecoder.decode(outputtype)
        } catch {
            Log.debug("type decode error")
            return
        }

        // insert the path information into the document structure.
        swagger.add(path: route, method: method, id: id, inputtype: nil, responselist: responsetypes)

        // add model information into the document structure.
        swagger.add(model: t)

        // now walk all the unprocessed models and ensure they are processed.
        for t in Array(swagger.unprocessedTypes) {
            swagger.add(model: t)
        }
    }

    // Register a route in the SwaggerDocument.
    //
    // - Parameter route: The route to be registered.
    // - Parameter method: The http method name: one of 'get', 'patch', 'post', 'put'.
    // - Parameter id: Boolean indicator whether id is used.
    // - Parameter inputtype: The type of the input model to register.
    // - Parameter outputtype: The type of the output model to register.
    // - Parameter responsetypes: array of expected swagger response type objects.
    func registerRoute<I: Codable, O: Codable>(route: String, method: String, id: Bool, inputtype: I.Type, outputtype: O.Type, responsetypes: [SwaggerResponseType]) {
        Log.debug("Registering \(route) for \(method) method")

        let t1: TypeInfo
        do {
            t1 = try TypeDecoder.decode(inputtype)
        } catch {
            Log.debug("failed to decode input type")
            return
        }

        var t2: TypeInfo? = nil
        if inputtype != outputtype {
            do {
                t2 = try TypeDecoder.decode(outputtype)
            } catch {
                Log.debug("failed to decode output type")
                return
            }
        }

        // insert the path information into the document structure
        swagger.add(path: route, method: method, id: id, inputtype: "\(inputtype)", responselist: responsetypes)

        // add model information into the document structure.
        swagger.add(model: t1)
        if let t2 = t2 {
            swagger.add(model: t2)
        }

        // now walk all the unprocessed models and ensure they are processed.
        for t in Array(swagger.unprocessedTypes) {
            swagger.add(model: t)
        }
    }

    // Register a delete route in the SwaggerDocument.
    //
    // - Parameter route: The route to be registered.
    // - Parameter method: The http method name: one of 'get', 'patch', 'post', 'put'.
    func registerDelete(route: String, id: Bool, responsetypes: [SwaggerResponseType]) {
        Log.debug("Registering \(route) for delete method")

        // insert the path information into the document structure.
        swagger.add(path: route, method: "delete", id: id, inputtype: nil, responselist: responsetypes)
    }

    /// Register GET route
    ///
    /// - Parameter route: The route to register.
    /// - Parameter id: Boolean to indicate if id is used.
    /// - Parameter outputtype: The output object type.
    public func registerGetRoute<O: Codable>(route: String, id: Bool, outputtype: O.Type) {
        var responseTypes = [SwaggerResponseType]()
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: "\(O.self)"))
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: "RequestError"))
        registerRoute(route: route, method: "get", id: id, outputtype: O.self, responsetypes: responseTypes)
    }

    /// Register DELETE route
    ///
    /// - Parameter route: The route to register.
    /// - Parameter id: Boolean to indicate if id is used.
    public func registerDeleteRoute(route: String, id: Bool) {
        var responseTypes = [SwaggerResponseType]()
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: ""))
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: "RequestError"))
        registerDelete(route: route, id: id, responsetypes: responseTypes)
    }

    /// Register POST route that is handled by a CodableIdentifierClosure.
    ///
    /// - Parameter route: The route to register.
    /// - Parameter id: Boolean to indicate if id is used.
    /// - Parameter inputtype: The input object type.
    /// - Parameter outputtype: The output object type.
    public func registerPostRoute<I: Codable, O: Codable>(route: String, id: Bool, inputtype: I.Type, outputtype: O.Type) {
        var responseTypes = [SwaggerResponseType]()
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: "\(O.self)"))
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: "RequestError"))
        registerRoute(route: route, method: "post", id: id, inputtype: I.self, outputtype: O.self, responsetypes: responseTypes)
    }

    /// Register PUT route that is handled by a IdentifierCodableClosure.
    ///
    /// - Parameter route: The route to register.
    /// - Parameter id: Boolean to indicate if id is used.
    /// - Parameter inputtype: The input object type.
    /// - Parameter outputtype: The output object type.
    public func registerPutRoute<I: Codable, O: Codable>(route: String, id: Bool, inputtype: I.Type, outputtype: O.Type) {
        var responseTypes = [SwaggerResponseType]()
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: "\(O.self)"))
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: "RequestError"))
        registerRoute(route: route, method: "put", id: id, inputtype: I.self, outputtype: O.self, responsetypes: responseTypes)
    }

    /// Register PATCH route that is handled by an IdentifierCodableClosure.
    ///
    /// - Parameter route: The route to register.
    /// - Parameter id: Boolean to indicate if id is used.
    /// - Parameter inputtype: The input object type.
    /// - Parameter outputtype: The output object type.
    public func registerPatchRoute<I: Codable, O: Codable>(route: String, id: Bool, inputtype: I.Type, outputtype: O.Type) {
        var responseTypes = [SwaggerResponseType]()
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: "\(O.self)"))
        responseTypes.append(SwaggerResponseType(optional: true, array: false, type: "RequestError"))
        registerRoute(route: route, method: "patch", id: id, inputtype: I.self, outputtype: O.self, responsetypes: responseTypes)
    }
}
