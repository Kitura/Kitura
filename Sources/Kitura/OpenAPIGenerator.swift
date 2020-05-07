import Foundation
import TypeDecoder
import KituraContracts
import LoggerAPI

public enum OpenAPIVersion {
    case swagger2_0
    case openapi3_0
}

/// Namespace-like for the OpenAPI 3.0 documentation generation.
/// The documentation is a direct copy of the Open Specification document, slightly adjusted when needed.
/// see: swagger.io/specification/
public struct OpenAPI {

    private static func getTypeName(type: Any.Type) -> String {
        let fullName = String(reflecting: type)
        return removeFrameworkname(fullName: fullName)
    }
    
    private static func getTypeName(type: Any) -> String {
        let fullName = String(reflecting: type)
        return removeFrameworkname(fullName: fullName)
    }

    private static func getTypeName(typeInfo: TypeInfo) -> String {
        let fullName: String
        switch typeInfo {
        case .cyclic(let type):
            fullName = "\(String(reflecting: type))"
        case .dynamicKeyed:
            fullName = "\(typeInfo.description)"
        case .keyed(let original, _):
            fullName = "\(String(reflecting: original))"
        case .opaque(let type):
            fullName = "\(String(reflecting: type))"
        case .optional(let type):
            fullName = "\(type.debugDescription)"
        case .single(_, let type):
            fullName = "\(String(reflecting: type))"
        case .unkeyed(_, let type):
            fullName = "\(type.debugDescription)"
        }
        return removeFrameworkname(fullName: fullName)
    }

    private static func removeFrameworkname(fullName: String) -> String {
        let fullNameSplit = fullName.components(separatedBy: ".")
        if fullNameSplit.count <= 1 {
            return fullName
        } else {
            return fullNameSplit[1..<fullNameSplit.count].joined(separator: ".")
        }
    }

    private static var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate
    private static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate

    // Force-try is okay because we are compiling a known valid regex.
    // swiftlint:disable:next force_try
    private static let unkeyedTypeRegex = try! NSRegularExpression(pattern: "^([^{\\]]+)", options: [])

    // Force-try is okay because we are compiling a known valid regex.
    // swiftlint:disable:next force_try
    private static let tupleRegex = try! NSRegularExpression(pattern: "^\\(Optional\\(Swift\\.String\\), Optional\\(Swift\\.[a-zA-Z0-9]+\\)\\)$", options: [])

    /// An object representing a Server.
    public struct Server: Encodable, Hashable {
        /// A map between a variable name and its value.
        /// The value is used for substitution in the server's URL template.
        public struct Variable: Encodable {
            let `enum`: [String]
            let `default`: String
            let description: String

            public init(default: String, enum: [String] = [], description: String = "") {
                self.default = `default`
                self.enum = `enum`
                self.description = description
            }
        }

        let url: String
        let description: String
        let variables: [String: Server.Variable]

        public static func == (lhs: Server, rhs: Server) -> Bool {
            return lhs.url == rhs.url
        }

        #if swift(>=4.2)
        public func hash(into hasher: inout Hasher) {
            hasher.combine(url)
        }
        #else
        public var hashValue: Int { 
            return url.hashValue
        }
        #endif

        public init(url: String, description: String, variables: [String: Server.Variable] = [:]) {
            self.url = url
            self.description = description
            self.variables = variables
        }

        enum CodingKeys: String, CodingKey {
            case url, description, variables
        }

        // Custom encoding to ignore empty array or nil objects.
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.if(url, forKey: .url)
            try container.if(description, forKey: .description)
            try container.if(variables, forKey: .variables)
        }
    }

    /// Contact information for the exposed API.
    public struct Contact: Encodable {
        private let name: String?
        private let url: String?
        private let email: String?

        public init(name: String? = nil, url: String? = nil, email: String? = nil) {
            self.name = name
            self.url = url
            self.email = email
        }

        enum CodingKeys: String, CodingKey {
            case name, url, email
        }

        // Custom encoding to ignore empty array or nil objects.
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.if(name, forKey: .name)
            try container.if(url, forKey: .url)
            try container.if(email, forKey: .email)
        }
    }

    /// License information for the exposed API.
    public struct License: Encodable {
        private let name: String
        private let url: String?

        public init(name: String, url: String? = nil) {
            self.name = name
            self.url = url
        }

        enum CodingKeys: String, CodingKey {
            case name, url
        }

        // Custom encoding to ignore empty array or nil objects.
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.if(url, forKey: .url)
        }
    }

    /// The object provides metadata about the API.
    /// The metadata MAY be used by the clients if needed, and MAY be presented in editing or documentation generation tools for convenience.
    public struct Info: Encodable {
        public let title: String
        public let version: String
        public let description: String?
        public let termsOfService: String?
        public let contact: Contact?
        public let license: License?

        public init(title: String, version: String,
                    description: String? = nil, termsOfService: String? = nil, contact: Contact? = nil, license: License? = nil) {
            self.title = title
            self.version = version
            self.description = description
            self.termsOfService = termsOfService
            self.contact = contact
            self.license = license
        }

        enum CodingKeys: String, CodingKey {
            case title, version, description, termsOfService, contact, license
        }

        // Custom encoding to ignore empty array or nil objects.
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(title, forKey: .title)
            try container.encode(version, forKey: .version)
            try container.if(description, forKey: .description)
            try container.if(termsOfService, forKey: .termsOfService)
            try container.if(contact, forKey: .contact)
            try container.if(license, forKey: .license)
            try container.if(description, forKey: .description)
        }
    }

    /// Describes the operations available on a single path.
    /// A Path Item MAY be empty, due to ACL constraints.
    /// The path itself is still exposed to the documentation viewer but they will not know which operations and parameters are available.
    public struct PathItem: Encodable {
        private let ref: String?
        private let summary: String?
        private let description: String?
        private let get: Operation?
        private let put: Operation?
        private let post: Operation?
        private let delete: Operation?
        private let options: Operation?
        private let head: Operation?
        private let patch: Operation?
        private let trace: Operation?
        private let servers: Server?
        private let parameters: [Parameter]

        public init(get: Operation, parameters: [Parameter] = []) {
            self.get = get
            self.ref = nil
            self.summary = nil
            self.description = nil
            self.put = nil
            self.post = nil
            self.delete = nil
            self.options = nil
            self.head = nil
            self.patch = nil
            self.trace = nil
            self.servers = nil
            self.parameters = parameters
        }

        public init(post: Operation, parameters: [Parameter] = []) {
            self.get = nil
            self.ref = nil
            self.summary = nil
            self.description = nil
            self.put = nil
            self.post = post
            self.delete = nil
            self.options = nil
            self.head = nil
            self.patch = nil
            self.trace = nil
            self.servers = nil
            self.parameters = parameters
        }

        public init(put: Operation, parameters: [Parameter] = []) {
            self.get = nil
            self.ref = nil
            self.summary = nil
            self.description = nil
            self.put = put
            self.post = nil
            self.delete = nil
            self.options = nil
            self.head = nil
            self.patch = nil
            self.trace = nil
            self.servers = nil
            self.parameters = parameters
        }

        public init(patch: Operation, parameters: [Parameter] = []) {
            self.get = nil
            self.ref = nil
            self.summary = nil
            self.description = nil
            self.put = nil
            self.post = nil
            self.delete = nil
            self.options = nil
            self.head = nil
            self.patch = patch
            self.trace = nil
            self.servers = nil
            self.parameters = parameters
        }

        public init(delete: Operation, parameters: [Parameter] = []) {
            self.get = nil
            self.ref = nil
            self.summary = nil
            self.description = nil
            self.put = nil
            self.post = nil
            self.delete = delete
            self.options = nil
            self.head = nil
            self.patch = nil
            self.trace = nil
            self.servers = nil
            self.parameters = parameters
        }

        public init(
            ref: String?,
            summary: String?,
            description: String?,
            get: Operation?,
            put: Operation?,
            post: Operation?,
            delete: Operation?,
            options: Operation?,
            head: Operation?,
            patch: Operation?,
            trace: Operation?,
            servers: Server?,
            parameters: [Parameter]
        ) {
            self.ref = ref
            self.summary = summary
            self.description = description
            self.get = get
            self.put = put
            self.post = post
            self.delete = delete
            self.options = options
            self.head = head
            self.patch = patch
            self.trace = trace
            self.servers = servers
            self.parameters = parameters
        }

        public func merge(with path: PathItem) -> PathItem {
            return PathItem(
                ref: ref ?? path.ref,
                summary: self.summary ?? path.summary,
                description: self.description ?? path.description,
                get: self.get ?? path.get,
                put: self.put ?? path.put,
                post: self.post ?? path.post,
                delete: self.delete ?? path.delete,
                options: self.options ?? path.options,
                head: self.head ?? path.head,
                patch: self.patch ?? path.patch,
                trace: self.trace ?? path.trace,
                servers: self.servers ?? path.servers,
                parameters: self.parameters + path.parameters // todo: merge instead
            )
        } 

        enum CodingKeys: String, CodingKey {
            case ref = "$ref"
            case summary, description, get, put, post, delete, options, head, patch, trace, servers, parameters
        }

        // Custom encoding to ignore empty array or nil objects.
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.if(ref, forKey: .ref)
            try container.if(summary, forKey: .summary)
            try container.if(description, forKey: .description)
            try container.if(get, forKey: .get)
            try container.if(put, forKey: .put)
            try container.if(post, forKey: .post)
            try container.if(delete, forKey: .delete)
            try container.if(options, forKey: .options)
            try container.if(head, forKey: .head)
            try container.if(patch, forKey: .patch)
            try container.if(trace, forKey: .trace)
            try container.if(servers, forKey: .servers)
            try container.if(parameters, forKey: .parameters)
        }
    }

    /// Describes a single API operation on a path.
    public struct Operation: Encodable {
        private let tags: [String]
        private let summary: String?
        private let description: String?
        private let externalDocs: ExternalDocumentation?
        private let operationId: String?
        private let parameters: [Parameter]
        private let requestBody: RequestBody?
        private let responses: Dictionary<String, Response>
        private let callbacks: Dictionary<String, Callback>
        private let deprecated: Bool // default to false
        private let security: Set<SecurityRequirement>
        private let servers: Set<Server>

        public init(summary: String, responses: Dictionary<String, Response>,
                    parameters: [Parameter] = [],
                    description: String? = nil,
                    security: [SecurityRequirement] = [],
                    requestBody: RequestBody? = nil,
                    tags: [String] = [], 
                    servers: Set<Server> = Set(),
                    externalDocs: ExternalDocumentation? = nil,
                    operationId: String? = nil,
                    callbacks: Dictionary<String, Callback> = [:],
                    deprecated: Bool = false) {
            self.summary = summary
            self.responses = responses
            self.description = description
            self.tags = tags
            self.externalDocs = externalDocs
            self.operationId = operationId
            self.parameters = parameters
            self.requestBody = requestBody
            self.callbacks = callbacks
            self.deprecated = deprecated
            self.security = Set(security)
            self.servers = servers
        }

        
        enum CodingKeys: String, CodingKey {
            case tags, summary, description, externalDocs, operationId, parameters
            case requestBody, responses, callbacks, deprecated, security, servers
        }

        // Custom encoding to ignore empty array or nil objects.
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.if(tags, forKey: .tags)
            try container.if(summary, forKey: .summary)
            try container.if(description, forKey: .description)
            try container.if(description, forKey: .description)
            try container.if(externalDocs, forKey: .externalDocs)
            try container.if(operationId, forKey: .operationId)
            try container.if(parameters, forKey: .parameters)
            try container.if(requestBody, forKey: .requestBody)
            try container.if(responses, forKey: .responses)
            try container.if(callbacks, forKey: .callbacks)
            try container.encode(deprecated, forKey: .deprecated)
            try container.if(security, forKey: .security)
            try container.if(servers, forKey: .servers)
        }
    }

    /// Allows referencing an external resource for extended documentation.
    public struct ExternalDocumentation: Encodable {
        private let url: String
        private let description: String?

        public init(url: String, description: String? = nil) {
            self.url = url
            self.description = description
        }

        enum CodingKeys: String, CodingKey {
            case description, url
        }

        // Custom encoding to ignore empty array or nil objects.
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(url, forKey: .url)
            try container.if(description, forKey: .description)
        }
    }

    /// There are four possible parameter locations specified by the in field:
    public enum Location: String, Encodable {
        /// Parameters that are appended to the URL.
        /// For example, in `/items?id=###``, the query parameter is `id`.
        case query
        /// Custom headers that are expected as part of the request.
        /// Note that RFC7230 states header names are case insensitive.
        case header
        /// Used together with Path Templating, where the parameter value is actually part of the operation's URL.
        /// This does not include the host or base path of the API.
        /// For example, in `/items/{itemId}``, the path parameter is `itemId`.
        case path
        /// Used to pass a specific cookie value to the API.
        case cookie
    }

    /// Describes a single operation parameter.
    /// A unique parameter is defined by a combination of a `name` and `location` (`in`).
    public struct Parameter: Encodable {
        private let name: String
        private let `in`: Location
        private let description: String?
        private let required: Bool?
        private let deprecated: Bool?
        private let allowEmptyValue: Bool?
        private let ref: Ref?
        private let content: Dictionary<String, Media>

        enum CodingKeys: String, CodingKey {
            case name, `in`, description, `required`, deprecated, allowEmptyValue, content
            case ref = "schema"
        }

        public init(name: String, `in` location: Location,
                    content: (key: String, entry: Media),
                    description: String? = nil,
                    required: Bool? = nil,
                    deprecated: Bool? = nil,
                    allowEmptyValue: Bool? = nil) {
            self.name = name
            self.in = location
            self.description = description
            self.required = required
            self.deprecated = deprecated
            self.allowEmptyValue = allowEmptyValue
            self.ref = nil
            self.content = [content.key: content.entry]
        }

        public init(schema: Schema, `in` location: Location,
                    description: String? = nil,
                    required: Bool? = nil,
                    deprecated: Bool? = nil,
                    allowEmptyValue: Bool? = nil) {
            self.name = schema.name
            self.in = location
            self.description = description
            self.required = required
            self.deprecated = deprecated
            self.allowEmptyValue = allowEmptyValue
            if location == .query {
                self.ref = nil
                var contents: Dictionary<String, Media> = [:]
                schema.properties.forEach { property in
                    property.value.forEach{ value in 
                        contents[property.key] = Media(value: value.value)
                    }
                }
                self.content = contents
            } else {
                self.ref = schema.ref
                self.content = [:]
            }
        }

        private init(name: String,
                     `in` location: Location,
                     description: String?,
                     required: Bool?,
                     deprecated: Bool?,
                     allowEmptyValue: Bool?,
                     ref: Ref?,
                     content: Dictionary<String, Media>) {
            self.name = name
            self.in = location
            self.description = description
            self.required = required
            self.deprecated = deprecated
            self.allowEmptyValue = allowEmptyValue
            self.ref = ref
            self.content = content
        }

        static func query(from schema: Schema) -> [Parameter] {
            var parameters: [Parameter] = []
            schema.properties.forEach { property in
                property.value.forEach{ value in
                    let media = Media(value: value.value)
                    parameters.append(Parameter(name: property.key,
                                      in: .query,
                                      description: nil,
                                      required: schema.required.contains(property.key),
                                      deprecated: false, // Not supported.
                                      allowEmptyValue: false, // Not supported.
                                      ref: nil,
                                      content: [value.key: media]))
                }
            }
            return parameters
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(`in`, forKey: .in)
            try container.if(description, forKey: .description)
            try container.if(required, forKey: .required)
            try container.if(deprecated, forKey: .deprecated)
            try container.if(allowEmptyValue, forKey: .allowEmptyValue)
            if let schema = self.ref {
                try container.encode(schema, forKey: .ref)
            } else if self.content.isEmpty == false {
                try container.encode(content, forKey: .content)
            } else {
                throw SwaggerGenerationError.invalidSwiftType
            }
        }
    }

    /// Describes a single request body.
    public struct RequestBody: Encodable {
        private let description: String?
        private let content: Dictionary<String, Media>
        private let required: Bool // defaults to false

        public init(content: (key: String, entry: Media),
                    description: String? = nil, required: Bool = false) {
            self.content = [content.key: content.entry]
            self.description = description
            self.required = required
        }

        enum CodingKeys: String, CodingKey {
            case description, required, content
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.if(description, forKey: .description)
            try container.if(required, forKey: .required)
            try container.encode(content, forKey: .content)
        }
    }

    /// Each Media Type Object provides schema and examples for the media type identified by its key.
    public struct Media: Encodable {
        private let schemaRef: Ref?
        private let schema: Schema?
        // private let example: Any? // Not supported
        private let examples: Dictionary<String, Example>?
        private let encoding: Dictionary<String, Encoding>?

        public init(schema: Schema,
                    examples: Dictionary<String, Example>? = nil,
                    encoding: Dictionary<String, Encoding>? = nil) {
            self.schema = schema
            self.schemaRef = nil
            self.examples = examples
            self.encoding = encoding
        }

        public init(schema: Ref,
                    examples: Dictionary<String, Example>? = nil,
                    encoding: Dictionary<String, Encoding>? = nil) {
            self.schemaRef = schema
            self.schema = nil
            self.examples = examples
            self.encoding = encoding
        }

        internal init(value: PropertyValue) {
            switch value {
                case .arrayref(let single):
                    self.schemaRef = Ref(ref: single.ref)
                    self.schema = nil
                case .nativearray(let native):
                    self.schema = Schema(plain: native.type ?? "")
                    self.schemaRef = nil
                case .singleref(let single):
                    self.schemaRef = Ref(ref: single.ref)
                    self.schema = nil
                case .string(let name):
                    self.schema = Schema(plain: name)
                    self.schemaRef = nil
                case .dict(let properties):
                    // unsupported
                    Log.error("Trying to encode a Media with a dictionary: \(properties).")
                    self.schema = nil
                    self.schemaRef = nil
            }
            self.examples = nil
            self.encoding = nil
        }

        enum CodingKeys: String, CodingKey {
            case schema, examples, encoding
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            if let schemaRef = self.schemaRef {
                try container.encode(schemaRef, forKey: .schema)
            } else if let schema = self.schema {
                try container.encode(schema, forKey: .schema)
            }
            try container.if(examples, forKey: .examples)
            try container.if(encoding, forKey: .encoding)
        }

    }

    /// A simple object to allow referencing other components in the specification, internally and externally.
    /// The Reference Object is defined by JSON Reference and follows the same structure, behavior and rules.
    /// For this specification, reference resolution is accomplished as defined by the JSON Reference specification and not by the JSON Schema specification.
    public struct Ref: Encodable {
        private let ref: String // to be serialized as $ref

        public init(ref: String) {
            self.ref = ref
        }

        enum CodingKeys: String, CodingKey {
            case ref = "$ref"
        }
    }

    typealias Property = Dictionary<String, PropertyValue>
    typealias Properties = Dictionary<String, Property>

    // processedSet & unprocessedSet are used for ensuring that models that are
    // only referenced from within another model are correctly processed.
    static var processedSet = Set<TypeInfo>()
    static var unprocessedSet = Set<TypeInfo>()

    /// The Schema Object allows the definition of input and output data types.
    /// These types can be objects, but also primitives and arrays.
    /// This object is an extended subset of the JSON Schema Specification Wright Draft 00.
    /// For more information about the properties, see JSON Schema Core and JSON Schema Validation.
    /// Unless stated otherwise, the property definitions follow the JSON Schema.
    public struct Schema: Encodable {
        public private(set) var name: String
        internal private(set) var properties: Properties
        private let _type: String
        internal private(set) var required: [String]
        private var items: Ref? = nil

        public var ref: Ref { return OpenAPI.Ref(ref: "#/components/schemas/\(name)") }

        enum CodingKeys: String, CodingKey {
            case _type = "type"
            case properties, required, items
        }

        public init(array: Schema) {
            self._type = "array"
            self.items = array.ref
            self.name = "Array of \(array.name)"
            self.properties = [:]
            self.required = []
        }

        public init(plain: String) {
            self.name = plain
            self._type = plain
            self.properties = [:]
            self.required = []
        }

        public init<Id: Identifier>(plain: Id.Type) {
            if plain is Int.Type || plain is Int8.Type ||
            plain is UInt.Type || plain is UInt8.Type {
                self.name = "integer"
                self._type = "integer"
            } else if plain is Float.Type || plain is Double.Type {
                self.name = "number"
                self._type = "number"
            } else if plain is String.Type {
                self.name = "string"
                self._type = "string"
            } else if plain is Bool.Type {
                self.name = "boolean"
                self._type = "boolean"
            } else {
                self.name = "\(plain)"
                self._type = "\(plain)"
            }
            self.properties = [:]
            self.required = []
        }

        public init<O: Codable>(from object: O.Type) throws {
            self._type = "object"
            self.name = "\(type(of: object))".replacingOccurrences(of: ".Type", with: "")
            let typeInfo: TypeInfo = try TypeDecoder.decode(object)
            self.properties = [:]
            self.required = []
            let modelInfo = try buildModel(typeInfo)
            self.properties = modelInfo.properties
            self.required = modelInfo.required.count > 0 ? Array(modelInfo.required) : []
        }

        public init?(from typeInfo: TypeInfo) {
            self.properties = [:]
            self.required = []
            switch typeInfo {
                case .keyed(let name, _):
                    self.name = "\(type(of: name))".replacingOccurrences(of: ".Type", with: "")
                    self._type = "object"
                    guard let modelInfo = try? buildModel(typeInfo) else { return nil }
                    self.properties = modelInfo.properties
                    self.required = modelInfo.required.count > 0 ? Array(modelInfo.required) : []
                case .unkeyed(_, let arrayType):
                    // A type nested in an array. Process the array's type
                    OpenAPI.unprocessedSet.insert(arrayType)
                    return nil
                case .dynamicKeyed(_, _, let dictionaryValueType):
                    // A type nested within a dictionary. Process the dictionary's value type
                    Log.debug("Model nested in dictionary, type = \(dictionaryValueType.debugDescription)")
                    OpenAPI.unprocessedSet.insert(dictionaryValueType)
                    return nil
                case .single(let swiftType, let encodedType):
                    // A type that encodes to a single value: this does not need to be modelled
                    let model = OpenAPI.getTypeName(type: swiftType)
                    if swiftType == encodedType {
                        // This Swift type is a basic type, eg. String
                        Log.debug("Model not required for type '\(typeInfo.debugDescription)'")
                    } else {
                        // This Swift type encodes to a single-value type, eg. UUID -> String
                        Log.debug("Model '\(model)' has a single encoded value of type: '\(encodedType)'")
                    }
                    return nil
                default:
                    return nil
            }
        }

        private func buildModel(_ typeInfo: TypeInfo?) throws -> (properties: Properties, required: Set<String>) {
            var modelProperties = Properties()
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
                OpenAPI.unprocessedSet.remove(typeInfo)
                OpenAPI.processedSet.insert(typeInfo)
            } else {
                // This should not occur: addModel should only call buildModel for a keyed type
                Log.error("Expected a top-level (keyed) type, but received: \(typeInfo.debugDescription)")
            }
            return (properties: modelProperties, required: required)
        }

        func decomposeType(_ typeInfo: TypeInfo, name: String, isArray array: Bool=false, isRequired required: Bool=true) -> (SwaggerProperty, Bool) {
            var property = SwaggerProperty()

            switch typeInfo {
            case .keyed(let type, _):
                // found a keyed item, this is an embedded model that needs to be
                // turned into a separate definition and a ref to it placed here.
                addModel(model: typeInfo, forSwiftType: type)
                let typeName = OpenAPI.getTypeName(type: type)
                property["$ref"] = .string("#/components/schemas/\(typeName)")
                return (property, required == true)
            case .dynamicKeyed(_, _ /*let keyTypeInfo*/, let valueTypeInfo):
                // found a Dictionary, this needs to be mapped to an "object" type with additionalProperties
                property["type"] = .string("object")
                let (prop, optional) = decomposeType(valueTypeInfo, name: name, isArray: array, isRequired: required)
                property["additionalProperties"] = .dict(prop)
                return (property, optional)
            case .unkeyed(_, let elementTypeInfo):
                // found an array.
                let typeName = self.getUnkeyedTypeName(OpenAPI.getTypeName(typeInfo: elementTypeInfo))
                if SwiftType.isBaseType(typeName) {
                    if let type = SwiftType(rawValue: typeName) {
                        if let format = type.swaggerFormat() {
                            property["items"] = .nativearray(NativeArraySchema(type: type.swaggerType(), format: format))
                        } else {
                            property["items"] = .nativearray(NativeArraySchema(type: type.swaggerType()))
                        }
                    }
                } else {
                    property["items"] = .arrayref(SingleReference(ref: String(describing: "#/components/schemas/\(typeName)")))
                }
                property["type"] = .string("array")

                // check that this model has been processed, if not add it to the notProcessed set.
                switch elementTypeInfo {
                case .single(_, let lowLevelType):
                    // Array contains a simple type
                    Log.debug("No need to process: \(lowLevelType)")
                case .cyclic(let cyclicType):
                    Log.debug("No need to process: \(cyclicType)")
                default:
                    // Array contains a complex type: check whether this model needs processing
                    if OpenAPI.processedSet.contains(elementTypeInfo) == false {
                        Log.debug("Adding unprocessed model: \(elementTypeInfo.debugDescription)")
                        OpenAPI.unprocessedSet.insert(elementTypeInfo)
                    } else {
                        Log.debug("Already processed \(elementTypeInfo.debugDescription)")
                    }
                }
                return (property, required == true)
            case .cyclic(let type):
                property["type"] = .string(OpenAPI.getTypeName(type: type))
                return (property, required == true)
            case .single(let swiftType, let serializedType):
                do {
                    let property: SwaggerProperty
                    // FIXME: This only works if encoders are configured _before_ route registration.
                    if swiftType is Date.Type {
                        // Note: We do not handle a difference in input vs. output encoding - although it
                        // is possible to configure Kitura this way, it is not compatible with REST.
                        switch OpenAPI.dateEncodingStrategy {
                        case .iso8601, .formatted(_):
                            // Date is serialized to a string
                            property = try swaggerPropertyFromSwiftType(String.self)
                        case .secondsSince1970, .millisecondsSince1970:
                            // Date is serialized to an integer value
                            property = try swaggerPropertyFromSwiftType(Int64.self)
                        default:
                            // Default encoding for Date (Double)
                            property = try swaggerPropertyFromSwiftType(serializedType)
                        }
                    } else {
                        property = try swaggerPropertyFromSwiftType(serializedType)
                    }
                    return (property, required == true)
                } catch {
                    Log.warning("Failed to derive a SwaggerProperty from type '\(serializedType)': \(error)")
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

        func addModel(model typeInfo: TypeInfo, forSwiftType: Any.Type? = nil) {
            // from the typeinfo we can extract the model name and all subordinate structures.

            // Remove this typeInfo from the unprocessed set, as we're about to process it
            OpenAPI.unprocessedSet.remove(typeInfo)

            // get the model name.
            switch typeInfo {
            case .keyed(let name, _):
                Log.verbose("Registerm model: '\(name)'")
                OpenAPI.unprocessedSet.insert(typeInfo)
            case .unkeyed(_, let arrayType):
                // A type nested in an array. Process the array's type
                Log.debug("Model nested in array, type = \(arrayType.debugDescription)")
                OpenAPI.unprocessedSet.insert(arrayType)
            case .dynamicKeyed(_, _, let dictionaryValueType):
                // A type nested within a dictionary. Process the dictionary's value type
                Log.debug("Model nested in dictionary, type = \(dictionaryValueType.debugDescription)")
                OpenAPI.unprocessedSet.insert(dictionaryValueType)
            case .single(let swiftType, let encodedType):
                // A type that encodes to a single value: this does not need to be modelled
                let model = OpenAPI.getTypeName(type: swiftType)
                if swiftType == encodedType {
                    // This Swift type is a basic type, eg. String
                    Log.debug("Model not required for type '\(typeInfo.debugDescription)'")
                } else {
                    // This Swift type encodes to a single-value type, eg. UUID -> String
                    Log.debug("Model '\(model)' has a single encoded value of type: '\(encodedType)'")
            }
            default:
                Log.debug("Model not required for type '\(typeInfo.debugDescription)'")
            }
        }

        // Takes a type name for an unKeyed type (an Array) and strips the array
        // square brackets to give the type contained within the array.
        //
        // - Parameter _: A type name for a typedecoder unKeyed type (an array type).
        // - Returns: String name of the type contained within the array.
        func getUnkeyedTypeName(_ type: String) -> String {
            var arrayType = ""
            let nsType = NSString(string: type)
            let match = OpenAPI.unkeyedTypeRegex.matches(in: type, options: [], range: NSRange(location: 0, length: type.count))
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
            var swiftTypeStr = OpenAPI.getTypeName(type: theSwiftType)
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

        // Determine if the type passed is a Dictionary.
        //
        // - Parameter _: Any swift type.
        // - Returns: Bool, True if the type passed in was originally a Swift dictionary.
        func isDictEncodedAsTuple(_ type: Any) -> Bool {
            let typeStr = "\(type)"
            let match = OpenAPI.tupleRegex.matches(in: typeStr, options: [], range: NSRange(location: 0, length: typeStr.count))
            return match.count == 1
        }

        // Custom encoding to ignore empty array
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(_type, forKey: ._type)
            try container.if(properties, forKey: .properties)
            try container.if(required, forKey: .required)
            try container.if(items, forKey: .items)
        }
    }

    /// Describe a single Example.
    public struct Example: Encodable {
        private let summary: String?
        private let description: String?
        private let value: String?
        private let externalValue: String?

        public init(summary: String?, description: String?, value: String? = nil) {
            self.summary = summary
            self.description = description
            self.value = value
            self.externalValue = nil
        }

        public init(summary: String?, description: String?, externalValue: String? = nil) {
            self.summary = summary
            self.description = description
            self.externalValue = externalValue
            self.value = nil
        }

        enum CodingKeys: String, CodingKey {
            case summary, description, value, externalValue
        }

        // Custom encoding to ignore empty array or nil objects.
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.if(summary, forKey: .summary)
            try container.if(description, forKey: .description)
            try container.if(value, forKey: .value)
            try container.if(externalValue, forKey: .externalValue)
        }
    }

    /// A single encoding definition applied to a single schema property.
    public struct Encoding: Encodable {
        private let contentType: String?
        private let headers: Dictionary<String, Header>
        private let style: String?
        private let explode: Bool?
        private let allowReserved: Bool?

        public init(contentType: String? = nil,
                    headers: Dictionary<String, Header>,
                    style: String? = nil,
                    explode: Bool? = nil,
                    allowReserved: Bool? = nil) {
            self.contentType = contentType
            self.headers = headers
            self.style = style
            self.explode = explode
            self.allowReserved = allowReserved
        }

        enum CodingKeys: String, CodingKey {
            case contentType, headers, style, explode, allowReserved, license
        }

        // Custom encoding to ignore empty array or nil objects.
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.if(contentType, forKey: .contentType)
            try container.if(headers, forKey: .headers)
            try container.if(style, forKey: .style)
            try container.if(explode, forKey: .explode)
            try container.if(allowReserved, forKey: .allowReserved)
        }
    }

    /// The Header Object follows the structure of the Parameter Object with the following changes:
    ///  1. `name` MUST NOT be specified, it is given in the corresponding headers map.
    ///  2. `in` MUST NOT be specified, it is implicitly in `header`.
    ///  3. All traits that are affected by the location MUST be applicable to a location of `header` (for example, style).
    public struct Header: Encodable {
        private let description: String?
        private let required: Bool?
        private let deprecated: Bool?
        private let allowEmptyValue: Bool?

        public init(description: String? = nil,
                    required: Bool? = nil,
                    deprecated: Bool? = nil,
                    allowEmptyValue: Bool? = nil) {
            self.description = description
            self.required = required
            self.deprecated = deprecated
            self.allowEmptyValue = allowEmptyValue
        }

        enum CodingKeys: String, CodingKey {
            case description, required, deprecated, allowEmptyValue
        }

        // Custom encoding to ignore empty array or nil objects.
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.if(description, forKey: .description)
            try container.if(required, forKey: .required)
            try container.if(deprecated, forKey: .deprecated)
            try container.if(allowEmptyValue, forKey: .allowEmptyValue)
        }
    }

    /// Describes a single response from an API Operation, including design-time, static `links` to operations based on the response.
    public struct Response: Encodable {
        private let description: String
        private let content: Dictionary<String, Media>
        private let required: Bool?

        public init(description: String, content: Dictionary<String, Media> = [:], required: Bool? = nil) {
            self.description = description
            self.content = content
            self.required = required
        }

        enum CodingKeys: String, CodingKey {
            case description, content, required, allowEmptyValue
        }

        // Custom encoding to ignore empty array or nil objects.
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(description, forKey: .description)
            try container.if(content, forKey: .content)
            try container.if(required, forKey: .required)
        }
    }

    /// A map of possible out-of band callbacks related to the parent operation.
    /// Each value in the map is a Path Item Object that describes a set of requests that may be initiated by the API provider and the expected responses.
    /// The key value used to identify the path item object is an expression, evaluated at runtime, that identifies a URL to use for the callback operation.
    public struct Callback: Encodable {
        // Not supported.
    }

    /// Configuration details for a supported OAuth Flow
    public struct OAuthFlow: Encodable {
        private let authorizationUrl: String? // Only for oauth2('implicit', 'authorizationCode')
        private let tokenUrl: String? // Only for oauth2('password','clientCredentials', 'authorizationCode')
        private let refreshUrl: String?
        private let scopes: Dictionary<String, String> // Can be empty, must be there!

        enum CodingKeys: String, CodingKey {
            case authorizationUrl, tokenUrl, refreshUrl, scopes
        }

        public init(scopes: Dictionary<String, String> = [:],
                    refreshUrl: String? = nil,
                    authorizationUrl: String? = nil,
                    tokenUrl: String? = nil) {
            self.scopes = scopes
            self.refreshUrl = refreshUrl
            self.authorizationUrl = authorizationUrl
            self.tokenUrl = tokenUrl
        } 

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.if(authorizationUrl, forKey: .authorizationUrl)
            try container.if(tokenUrl, forKey: .tokenUrl)
            try container.if(refreshUrl, forKey: .refreshUrl)
            try container.encode(scopes, forKey: .scopes)
        }
    }

    /// Allows configuration of the supported OAuth Flows.
    public struct OAuthFlows: Encodable {
        private let implicit: OAuthFlow?
        private let password: OAuthFlow?
        private let clientCredentials: OAuthFlow?
        private let authorizationCode: OAuthFlow?

        enum CodingKeys: String, CodingKey {
            case implicit, password, clientCredentials, authorizationCode
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.if(implicit, forKey: .implicit)
            try container.if(password, forKey: .password)
            try container.if(clientCredentials, forKey: .clientCredentials)
            try container.if(authorizationCode, forKey: .authorizationCode)
        }
    }

    /// Lists the required security schemes to execute this operation.
    /// The name used for each property MUST correspond to a security scheme declared in the `Security Schemes` under the `Components` object.
    public typealias SecurityRequirement = Dictionary<String, [String]>
    /// Lists the required security schemes.
    public typealias SecuritySchemes = Dictionary<String, SecurityScheme>

    /// Defines a security scheme that can be used by the operations.
    /// Supported schemes are HTTP authentication, an API key (either as a header, a cookie parameter or as a query parameter),
    /// OAuth2's common flows (implicit, password, client credentials and authorization code) as defined in RFC6749, and OpenID Connect Discovery.
    public struct SecurityScheme: Encodable {
        public enum SecurityType: String, Codable {
            case apiKey
            case http
            case oauth2
            case openIdConnect
        }

        public enum AuthenticationScheme: String, Codable {
            case basic                              //[RFC7617]	
            case bearer	                            //[RFC6750]	
            case digest	                            //[RFC7616]	
            case hoba	                            //[RFC7486, Section 3]
            case mutual	                            //[RFC8120]	
            case negotiate                          //[RFC4559, Section 3]
            case oauth	                            //[RFC5849, Section 3.5.1]	
            case scram_sha_1   = "scram-sha-1"      //[RFC7804]	
            case scram_sha_256 = "scram-sha-256"    //[RFC7804]	
            case vapid                              //[RFC 8292, Section 3]
        }

        private let _type: SecurityType
        private let description: String?

        // Apply only to `apiKey`
        private let name: String?
        private let `in`: Location? // Path is not allowed here.

        // Apply only to `http`
        private let scheme: AuthenticationScheme?
        private let bearerFormat: String? // Bearer-only

        // Apply only to `oauth2`
        private let flows: OAuthFlows?

        // Apply only to `openIdConnect`
        private let openIdConnectUrl: String?

        // Create an API key scheme
        public init(name: String, in location: Location, 
                    description: String? = nil) {
            self._type = .apiKey
            self.description = description
            // API key
            self.name = name
            self.in = location
            // other
            self.scheme = nil
            self.bearerFormat = nil
            self.flows = nil
            self.openIdConnectUrl = nil
        }

        // Create an HTTP scheme
        public init(scheme: AuthenticationScheme,
                    bearerFormat: String?,
                    description: String? = nil) {
            self._type = .http
            self.description = description
            // HTTP
            self.scheme = scheme
            self.bearerFormat = bearerFormat
            // other
            self.name = nil
            self.in = nil
            self.flows = nil
            self.openIdConnectUrl = nil
        }

        // Create an OAuth2 scheme
        public init(flows: OAuthFlows,
                    description: String? = nil) {
            self._type = .oauth2
            self.description = description
            // OAuth2
            self.flows = flows
            // others
            self.name = nil
            self.in = nil
            self.scheme = nil
            self.bearerFormat = nil
            self.openIdConnectUrl = nil
        }

        // Create an OpenID connect scheme
        public init(openIdConnectUrl: String,
                    description: String? = nil) {
            self._type = .openIdConnect
            self.description = description
            // OpenID connect
            self.openIdConnectUrl = openIdConnectUrl
            // others
            self.name = nil
            self.in = nil
            self.scheme = nil
            self.bearerFormat = nil
            self.flows = nil
        }

        enum CodingKeys: String, CodingKey {
            case _type = "type"
            case description, name, `in`, scheme, bearerFormat, flows, openIdConnectUrl
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.if(_type, forKey: ._type)
            try container.if(description, forKey: .description)
            try container.if(name, forKey: .name)
            try container.if(`in`, forKey: .in)
            try container.if(scheme, forKey: .scheme)
            try container.if(bearerFormat, forKey: .bearerFormat)
            try container.if(flows, forKey: .flows)
            try container.if(openIdConnectUrl, forKey: .openIdConnectUrl)
        }
    }

    /// The Link object represents a possible design-time link for a response.
    /// The presence of a link does not guarantee the caller's ability to successfully invoke it, rather it provides a known relationship and traversal mechanism between responses and other operations.
    public struct Link: Encodable {
        // Not supported! 
    }

    /// Holds a set of reusable objects for different aspects of the OAS.
    /// All objects defined within the components object will have no effect on the API unless they are explicitly referenced from properties outside the components object.
    public struct Components: Encodable {
        var schemas: Dictionary<String, Schema>
        var responses: Dictionary<String, Response>
        var parameters: Dictionary<String, Parameter>
        var examples: Dictionary<String, Example>
        var requestBody: Dictionary<String, RequestBody>
        var headers: Dictionary<String, Header>
        var securitySchemes: SecuritySchemes
        var links: Dictionary<String, Link>
        var callbacks: Dictionary<String, Callback>
        
        public init(schemes: SecuritySchemes = [:]) {
            self.schemas = [:]
            self.responses = [:]
            self.parameters = [:]
            self.examples = [:]
            self.requestBody = [:]
            self.headers = [:]
            self.securitySchemes = schemes
            self.links = [:]
            self.callbacks = [:]
        }

        public mutating func add(schema: Schema) {
            self.schemas[schema.name] = schema
        }

        public mutating func add(schemes: SecuritySchemes) {
            for (name, scheme) in schemes {
                self.securitySchemes[name] = scheme
            }
        }

        public mutating func merge(components: Components) {
            for (name, schema) in components.schemas {
                self.schemas[name] = schema
            }
        }

        public mutating func add(components: Components) {
            self.schemas.merge(components.schemas){ (current, new) in new }
            self.responses.merge(components.responses){ (current, new) in new }
            self.parameters.merge(components.parameters){ (current, new) in new }
            self.examples.merge(components.examples){ (current, new) in new }
            self.requestBody.merge(components.requestBody){ (current, new) in new }
            self.headers.merge(components.headers){ (current, new) in new }
            self.securitySchemes.merge(components.securitySchemes){ (current, new) in new }
            self.links.merge(components.links){ (current, new) in new }
            self.callbacks.merge(components.callbacks){ (current, new) in new }
        }

        enum CodingKeys: String, CodingKey {
            case schemas, responses, parameters, examples, requestBody, headers, securitySchemes, links, callbacks
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.if(schemas, forKey: .schemas)
            try container.if(responses, forKey: .responses)
            try container.if(parameters, forKey: .parameters)
            try container.if(examples, forKey: .examples)
            try container.if(requestBody, forKey: .requestBody)
            try container.if(headers, forKey: .headers)
            try container.if(securitySchemes, forKey: .securitySchemes)
            try container.if(links, forKey: .links)
            try container.if(callbacks, forKey: .callbacks)
        }
    }

    /// Adds metadata to a single tag that is used by the Operation Object.
    /// It is not mandatory to have a Tag Object per tag defined in the Operation Object instances.
    public struct Tag: Encodable {
        public let name: String
        private let description: String?
        private let externalDocs: ExternalDocumentation?

        public init(name: String, description: String? = nil, externalDocs: ExternalDocumentation? = nil) {
            self.name = name
            self.description = description
            self.externalDocs = externalDocs
        }
    }

    /// This is the root document object of the OpenAPI documentation.
    public struct Document: Encodable {
        public let openapi: String
        public let info: Info
        public private(set) var servers: Set<Server>
        public private(set) var tags: [Tag]?
        public private(set) var externalDocs: ExternalDocumentation?

        public private(set) var paths: Dictionary<String, PathItem>
        public private(set) var components: Components
        public private(set) var security: Set<SecurityRequirement>
        public internal(set) var subRoute: String = ""

        public init(info: Info,
                    servers: [Server] = [],
                    tags: [Tag]? = nil) {
            self.openapi = "3.0.0"
            self.info = info
            self.servers = Set(servers.isEmpty ? [Server(url: "/", description: "")] : servers)
            self.tags = tags
            self.paths = [:]
            self.components = Components()
            self.security = Set()
            self.externalDocs = nil
        }

        public var tagNames: [String] {
            return tags?.map{ $0.name } ?? []
        }

        enum CodingKeys: String, CodingKey {
            case openapi, info, servers, tags, externalDocs, paths, components, security
        }

        mutating func serializeAPI(format: SwaggerDocumentFormat) throws -> String? {
            return try serialize()
        }

        public func serialize() throws -> String? {
            let encoder = JSONEncoder()
            if #available(OSX 10.13, iOS 11.0, *) {
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            } else {
                // Fallback on earlier versions
                encoder.outputFormatting = .prettyPrinted
            }
            let encodedData = try encoder.encode(self)
            return String(data: encodedData, encoding: .utf8)?.replacingOccurrences(of: "\\/", with: "/")
        }

        public mutating func add(path: PathItem, for route: String) {
            let completeRoute = subRoute + route 
            if let existingPath = paths[completeRoute] {
                paths[completeRoute] = existingPath.merge(with: path)
            } else {
                self.paths[completeRoute] = path
            }
        }

        public mutating func add(component: Schema) {
            self.components.add(schema: component)

            for unprocessed in Array(OpenAPI.unprocessedSet) {
                OpenAPI.unprocessedSet.remove(unprocessed)
                Log.debug("Processing unprocessed model: \(unprocessed.debugDescription)")
                if let schema = OpenAPI.Schema(from: unprocessed) {
                    self.components.add(schema: schema)
                }
            }
        }

        public mutating func add(components: Components) {
            self.components.merge(components: components)
        }

        public mutating func add(security schemes: SecuritySchemes) {
            self.components.add(schemes: schemes)
            var newSchemes: [SecurityRequirement] = []
            schemes.forEach { key, _ in
                newSchemes.append([key: []])
            }
            self.security = Set(Array(security) + newSchemes)
        }

        public mutating func merge(with document: Document) {
            self.components.add(components: document.components)
            self.paths.merge(document.paths){ (current, new) in new }
            self.servers.formUnion(document.servers)
            self.security.formUnion(document.security)
        }
    }
}

#if swift(>=4.2)
// Nothing to do regarding the dictionary conformancy.
#elseif swift(>=4.1)
extension Dictionary: Hashable where Value: Equatable {
    // Simple hash
    public var hashValue: Int {
        return self.keys.reduce(0){ $0 << 2 | $1.hashValue }
    }
}
#elseif swift(>=4.0)
extension Dictionary: Hashable {
    // Simple hash
    public var hashValue: Int {
        return self.keys.reduce(0){ $0 << 2 | $1.hashValue }
    }

    // Assess only keys.
    public static func ==(lhs: Dictionary, rhs: Dictionary) -> Bool {
        return lhs.keys == rhs.keys
    }
}
#endif

extension Router {

    // Register the middlewares extra parameters and security schemes within the document.
    internal func register(
        middleware1: TypeSafeMiddleware.Type? = nil, 
        middleware2: TypeSafeMiddleware.Type? = nil,
        middleware3: TypeSafeMiddleware.Type? = nil) -> (parameters: [OpenAPI.Parameter], security: [OpenAPI.SecurityRequirement]) {
        var security: [OpenAPI.SecurityRequirement] = []
        for middleware in  [middleware1, middleware2, middleware3] {
            if let schemes = middleware?.securitySchemes {
                for (key, _) in schemes {
                    security.append([ key : [] ])
                }
                self.openapi.add(security: schemes)
            }
        }
        
        let parameters1 = middleware1?.parameters ?? []
        let parameters2 = middleware2?.parameters ?? [] 
        let parameters3 = middleware3?.parameters ?? []
        
        return (parameters: parameters1 + parameters2 + parameters3, security: security)
    }

    /// Register GET route
    ///
    /// - Parameter route: The route to register.
    /// - Parameter outputType: The output object type.
    /// - Parameter middleware1: Optional the first middleware applied to the route.
    /// - Parameter middleware2: Optional the second middleware applied to the route.
    /// - Parameter middleware3: Optional the third middleware applied to the route.
    public func registerGetRouteOpenAPI<O: Codable>(
        route: String, outputType: O.Type, outputIsArray: Bool = false,
        middleware1: TypeSafeMiddleware.Type? = nil, middleware2: TypeSafeMiddleware.Type? = nil, middleware3: TypeSafeMiddleware.Type? = nil) {
        do {
            let middlewares = register(middleware1: middleware1, middleware2: middleware2, middleware3: middleware3)

            let schema = try OpenAPI.Schema(from: outputType)
            let arraySchema = OpenAPI.Schema(array: schema)
            let pathItem = OpenAPI.PathItem(
                get: OpenAPI.Operation(
                    summary: "Return \(outputIsArray ? "an array of" : "a single") \(schema.name)",
                    responses: [
                        "\(HTTPStatusCode.OK.rawValue)": OpenAPI.Response(
                            description: "OK",
                            content: ["application/json" : (outputIsArray ? OpenAPI.Media(schema: arraySchema) : OpenAPI.Media(schema: schema.ref))]),
                    ],
                    parameters: middlewares.parameters,
                    security: middlewares.security,
                    tags: self.openapi.tagNames,
                    servers: self.openapi.servers
                )
            )
            self.openapi.add(path: pathItem, for: route)
            self.openapi.add(component: schema)
        } catch let error {
            Log.error("Cannot register the route GET \(route): \(error)")
        }
    }

    /// Register GET route
    ///
    /// - Parameter route: The route to register.
    /// - Parameter id: The id type.
    /// - Parameter outputtype: The output object type.
    /// - Parameter middleware1: Optional the first middleware applied to the route.
    /// - Parameter middleware2: Optional the second middleware applied to the route.
    /// - Parameter middleware3: Optional the third middleware applied to the route.
    public func registerGetRouteOpenAPI<Id: Identifier, O: Codable>(
        route: String, id: Id.Type, outputType: O.Type, outputIsArray: Bool = false,
        middleware1: TypeSafeMiddleware.Type? = nil, middleware2: TypeSafeMiddleware.Type? = nil, middleware3: TypeSafeMiddleware.Type? = nil) {
        do {
            let middlewares = register(middleware1: middleware1, middleware2: middleware2, middleware3: middleware3)

            let schema = try OpenAPI.Schema(from: outputType)
            let arraySchema = OpenAPI.Schema(array: schema)
            let idSchema = OpenAPI.Schema(plain: id)
            let pathItem = OpenAPI.PathItem(
                get: OpenAPI.Operation(
                    summary: "Return \(outputIsArray ? "an array of" : "a single") \(schema.name)",
                    responses: [
                        "\(HTTPStatusCode.OK.rawValue)": OpenAPI.Response(
                            description: "OK",
                            content: ["application/json": (outputIsArray ? OpenAPI.Media(schema: arraySchema) : OpenAPI.Media(schema: schema.ref))]),
                    ],
                    parameters: [
                        OpenAPI.Parameter(
                            name: "id",
                            in: .path,
                            content: ("id", OpenAPI.Media(schema: idSchema)),
                            description: "The id of the \(schema.name)",
                            required: true)
                    ] + middlewares.parameters,
                    security: middlewares.security,
                    tags: self.openapi.tagNames,
                    servers: self.openapi.servers
                )
            )
            self.openapi.add(path: pathItem, for: route)
            self.openapi.add(component: schema)
        } catch let error {
            Log.error("Cannot register the route GET \(route)/\(id): \(error)")
        }
    }
    
    /// Register GET route
    ///
    /// - Parameter route: The route to register.
    /// - Parameter queryParams: The query parameters.
    /// - Parameter optionalQParam: Flag to indicate that the query params are all optional.
    /// - Parameter outputType: The output object type.
    /// - Parameter middleware1: Optional the first middleware applied to the route.
    /// - Parameter middleware2: Optional the second middleware applied to the route.
    /// - Parameter middleware3: Optional the third middleware applied to the route.
    public func registerGetRouteOpenAPI<Q: QueryParams, O: Codable>(
        route: String, queryParams: Q.Type, optionalQParam: Bool, outputType: O.Type, outputIsArray: Bool = false, 
        middleware1: TypeSafeMiddleware.Type? = nil, middleware2: TypeSafeMiddleware.Type? = nil, middleware3: TypeSafeMiddleware.Type? = nil) {
        do {
            let middlewares = register(middleware1: middleware1, middleware2: middleware2, middleware3: middleware3)
            let schema = try OpenAPI.Schema(from: outputType)
            let arraySchema = OpenAPI.Schema(array: schema)
            let querySchema = try OpenAPI.Schema(from: queryParams)
            let pathItem = OpenAPI.PathItem(
                get: OpenAPI.Operation(
                    summary: "Return \(outputIsArray ? "an array of" : "a single") \(schema.name)",
                    responses: [
                        "\(HTTPStatusCode.OK.rawValue)": OpenAPI.Response(
                            description: "OK",
                            content: ["application/json" : (outputIsArray ? OpenAPI.Media(schema: arraySchema) : OpenAPI.Media(schema: schema.ref))]),
                        "\(HTTPStatusCode.badRequest.rawValue)": OpenAPI.Response(
                            description: "Bad request")
                    ],
                    parameters: OpenAPI.Parameter.query(from: querySchema)
                        + middlewares.parameters,
                    security: middlewares.security,
                    tags: self.openapi.tagNames,
                    servers: self.openapi.servers
                )
            )
            self.openapi.add(path: pathItem, for: route)
            self.openapi.add(component: schema)
            self.openapi.add(component: querySchema)
        } catch let error {
            Log.error("Cannot register the route GET \(route): \(error)")
        }
    }

    /// Register POST route that is handled by a CodableIdentifierClosure.
    ///
    /// - Parameter route: The route to register.
    /// - Parameter inputType: The input object type.
    /// - Parameter outputType: The output object type.
    /// - Parameter middleware1: Optional the first middleware applied to the route.
    /// - Parameter middleware2: Optional the second middleware applied to the route.
    /// - Parameter middleware3: Optional the third middleware applied to the route.
    public func registerPostRouteOpenAPI<I: Codable, O: Codable>(
        route: String, inputType: I.Type, outputType: O.Type,
        middleware1: TypeSafeMiddleware.Type? = nil, middleware2: TypeSafeMiddleware.Type? = nil, middleware3: TypeSafeMiddleware.Type? = nil) {
        do {
            let middlewares = register(middleware1: middleware1, middleware2: middleware2, middleware3: middleware3)

            let schema = try OpenAPI.Schema(from: outputType)
            let inputSchema = try OpenAPI.Schema(from: inputType)
            let pathItem = OpenAPI.PathItem(
                post: OpenAPI.Operation(
                    summary: "Create a \(schema.name)",
                    responses: [
                        "\(HTTPStatusCode.created.rawValue)": OpenAPI.Response(
                            description: "Content created",
                            content: ["application/json": OpenAPI.Media(schema: schema.ref)]),
                        "\(HTTPStatusCode.notFound.rawValue)": OpenAPI.Response(
                            description: "Not found"),
                        "\(HTTPStatusCode.unsupportedMediaType.rawValue)": OpenAPI.Response(
                            description: "Unsupported Media Type"),
                        "\(HTTPStatusCode.internalServerError.rawValue)": OpenAPI.Response(
                            description: "Internal Server Error"),
                        "\(HTTPStatusCode.unprocessableEntity.rawValue)": OpenAPI.Response(
                            description: "Unprocessable Entity"),
                    ],
                    parameters: middlewares.parameters,
                    security: middlewares.security,
                    requestBody: OpenAPI.RequestBody(
                        content: (key: "application/json", entry: OpenAPI.Media(schema: inputSchema.ref)),
                        description: "The content of a \(inputSchema.name)",
                        required: true),
                    tags: self.openapi.tagNames,
                    servers: self.openapi.servers
                )
            )
            self.openapi.add(path: pathItem, for: route)
            self.openapi.add(component: schema)
            self.openapi.add(component: inputSchema)
        } catch let error {
            Log.error("Cannot register the route POST \(route): \(error)")
        }
    }

    /// Register POST route that is handled by a CodableIdentifierClosure.
    ///
    /// - Parameter route: The route to register.
    /// - Parameter id: The id type.
    /// - Parameter inputType: The input object type.
    /// - Parameter outputType: The output object type.
    /// - Parameter middleware1: Optional the first middleware applied to the route.
    /// - Parameter middleware2: Optional the second middleware applied to the route.
    /// - Parameter middleware3: Optional the third middleware applied to the route.
    public func registerPostRouteOpenAPI<I: Codable, Id: Identifier, O: Codable>(
        route: String, id: Id.Type, inputType: I.Type, outputType: O.Type,
        middleware1: TypeSafeMiddleware.Type? = nil, middleware2: TypeSafeMiddleware.Type? = nil, middleware3: TypeSafeMiddleware.Type? = nil) {
        do {
            let middlewares = register(middleware1: middleware1, middleware2: middleware2, middleware3: middleware3)

            let schema = try OpenAPI.Schema(from: outputType)
            let inputSchema = try OpenAPI.Schema(from: inputType)
            let idSchema = OpenAPI.Schema(plain: id)
            let pathItem = OpenAPI.PathItem(
                post: OpenAPI.Operation(
                    summary: "Create a \(schema.name) with an id",
                    responses: [
                        "\(HTTPStatusCode.created.rawValue)": OpenAPI.Response(
                            description: "Content created",
                            content: ["application/json" : OpenAPI.Media(schema: schema.ref)]),
                        "\(HTTPStatusCode.notFound.rawValue)": OpenAPI.Response(
                            description: "Not found"),
                        "\(HTTPStatusCode.unsupportedMediaType.rawValue)": OpenAPI.Response(
                            description: "Unsupported Media Type"),
                        "\(HTTPStatusCode.internalServerError.rawValue)": OpenAPI.Response(
                            description: "Internal Server Error"),
                        "\(HTTPStatusCode.unprocessableEntity.rawValue)": OpenAPI.Response(
                            description: "Unprocessable Entity"),
                    ],
                    parameters: [
                        OpenAPI.Parameter(
                            name: "id",
                            in: .path,
                            content: ("id", OpenAPI.Media(schema: idSchema)),
                            description: "The id of the \(schema.name)",
                            required: true)
                    ] + middlewares.parameters,
                    security: middlewares.security,
                    requestBody: OpenAPI.RequestBody(
                        content: (key: "application/json", entry: OpenAPI.Media(schema: inputSchema.ref)),
                        description: "The content of a \(inputSchema.name)",
                        required: true),
                    tags: self.openapi.tagNames,
                    servers: self.openapi.servers
                )
            )
            self.openapi.add(path: pathItem, for: route)
            self.openapi.add(component: schema)
            self.openapi.add(component: inputSchema)
        } catch let error {
            Log.error("Cannot register the route POST \(route): \(error)")
        }
    }

    /// Register PUT route that is handled by a IdentifierCodableClosure.
    ///
    /// - Parameter route: The route to register.
    /// - Parameter id: The id type.
    /// - Parameter inputType: The input object type.
    /// - Parameter outputType: The output object type.
    /// - Parameter middleware1: Optional the first middleware applied to the route.
    /// - Parameter middleware2: Optional the second middleware applied to the route.
    /// - Parameter middleware3: Optional the third middleware applied to the route.
    public func registerPutRouteOpenAPI<Id: Identifier, I: Codable, O: Codable>(
        route: String, id: Id.Type, idReturned: Bool, inputType: I.Type, outputType: O.Type,
        middleware1: TypeSafeMiddleware.Type? = nil, middleware2: TypeSafeMiddleware.Type? = nil, middleware3: TypeSafeMiddleware.Type? = nil) {
         do {
            let middlewares = register(middleware1: middleware1, middleware2: middleware2, middleware3: middleware3)

            let schema = try OpenAPI.Schema(from: outputType)
            let inputSchema = try OpenAPI.Schema(from: inputType)
            let idSchema = OpenAPI.Schema(plain: id)
            let pathItem = OpenAPI.PathItem(
                put: OpenAPI.Operation(
                    summary: "Set a \(schema.name) with for an id",
                    responses: [
                        "\(HTTPStatusCode.OK.rawValue)": OpenAPI.Response(
                            description: "OK",
                            content: ["application/json" : OpenAPI.Media(schema: schema.ref)]),
                        "\(HTTPStatusCode.notFound.rawValue)": OpenAPI.Response(
                            description: "Not found"),
                        "\(HTTPStatusCode.unsupportedMediaType.rawValue)": OpenAPI.Response(
                            description: "Unsupported Media Type"),
                        "\(HTTPStatusCode.internalServerError.rawValue)": OpenAPI.Response(
                            description: "Internal Server Error"),
                    ],
                    parameters: [
                        OpenAPI.Parameter(
                            name: "id",
                            in: .path,
                            content: ("id", OpenAPI.Media(schema: idSchema)),
                            description: "The id of the \(schema.name)",
                            required: true)
                    ] + middlewares.parameters,
                    security: middlewares.security,
                    requestBody: OpenAPI.RequestBody(
                        content: (key: "application/json", entry: OpenAPI.Media(schema: inputSchema.ref)),
                        description: "The content of a \(inputSchema.name)",
                        required: true),
                    tags: self.openapi.tagNames,
                    servers: self.openapi.servers
                )
            )
            self.openapi.add(path: pathItem, for: route)
            self.openapi.add(component: schema)
            self.openapi.add(component: inputSchema)
        } catch let error {
            Log.error("Cannot register the route POST \(route): \(error)")
        }
    }

    /// Register PATCH route that is handled by an IdentifierCodableClosure.
    ///
    /// - Parameter route: The route to register.
    /// - Parameter id: The id type.
    /// - Parameter inputType: The input object type.
    /// - Parameter outputType: The output object type.
    /// - Parameter middleware1: Optional the first middleware applied to the route.
    /// - Parameter middleware2: Optional the second middleware applied to the route.
    /// - Parameter middleware3: Optional the third middleware applied to the route.
    public func registerPatchRouteOpenAPI<Id: Identifier, I: Codable, O: Codable>(
        route: String, id: Id.Type, idReturned: Bool, inputType: I.Type, outputType: O.Type,
        middleware1: TypeSafeMiddleware.Type? = nil, middleware2: TypeSafeMiddleware.Type? = nil, middleware3: TypeSafeMiddleware.Type? = nil) {
         do {
            let middlewares = register(middleware1: middleware1, middleware2: middleware2, middleware3: middleware3)

            let schema = try OpenAPI.Schema(from: outputType)
            let inputSchema = try OpenAPI.Schema(from: inputType)
            let idSchema = OpenAPI.Schema(plain: id)
            let pathItem = OpenAPI.PathItem(
                patch: OpenAPI.Operation(
                    summary: "Update a \(schema.name) from its id",
                    responses: [
                        "\(HTTPStatusCode.OK.rawValue)": OpenAPI.Response(
                            description: "OK",
                            content: ["application/json" : OpenAPI.Media(schema: schema.ref)]),
                        "\(HTTPStatusCode.notFound.rawValue)": OpenAPI.Response(
                            description: "Not found"),
                        "\(HTTPStatusCode.unsupportedMediaType.rawValue)": OpenAPI.Response(
                            description: "Unsupported Media Type"),
                        "\(HTTPStatusCode.internalServerError.rawValue)": OpenAPI.Response(
                            description: "Internal Server Error"),
                    ],
                    parameters: [
                        OpenAPI.Parameter(
                            name: "id",
                            in: .path,
                            content: ("id", OpenAPI.Media(schema: idSchema)),
                            description: "The id of the \(schema.name)",
                            required: true)
                    ] + middlewares.parameters,
                    security: middlewares.security,
                    requestBody: OpenAPI.RequestBody(
                        content: (key: "application/json", entry: OpenAPI.Media(schema: inputSchema.ref)),
                        description: "The content of a \(inputSchema.name)",
                        required: true),
                    tags: self.openapi.tagNames,
                    servers: self.openapi.servers
                )
            )
            self.openapi.add(path: pathItem, for: route)
            self.openapi.add(component: schema)
            self.openapi.add(component: inputSchema)
        } catch let error {
            Log.error("Cannot register the route POST \(route): \(error)")
        }
    }

    /// Register DELETE route
    ///
    /// - Parameter route: The route to register.
    /// - Parameter middleware1: Optional the first middleware applied to the route.
    /// - Parameter middleware2: Optional the second middleware applied to the route.
    /// - Parameter middleware3: Optional the third middleware applied to the route.
    public func registerDeleteRouteOpenAPI(route: String,
        middleware1: TypeSafeMiddleware.Type? = nil, middleware2: TypeSafeMiddleware.Type? = nil, middleware3: TypeSafeMiddleware.Type? = nil) {
        let middlewares = register(middleware1: middleware1, middleware2: middleware2, middleware3: middleware3)

        let pathItem = OpenAPI.PathItem(
            delete: OpenAPI.Operation(
                summary: "Delete a resource",
                responses: [
                    "\(HTTPStatusCode.OK.rawValue)": OpenAPI.Response(
                        description: "OK"),
                    "\(HTTPStatusCode.notFound.rawValue)": OpenAPI.Response(
                            description: "Not found"),
                ],
                parameters: middlewares.parameters,
                security: middlewares.security,
                    tags: self.openapi.tagNames,
                    servers: self.openapi.servers
            )
        )
        self.openapi.add(path: pathItem, for: route)
    }

    /// Register DELETE route
    ///
    /// - Parameter route: The route to register.
    /// - Parameter queryParams: The query parameters.
    /// - Parameter optionalQParam: Flag to indicate that the query params are all optional.
    /// - Parameter middleware1: Optional the first middleware applied to the route.
    /// - Parameter middleware2: Optional the second middleware applied to the route.
    /// - Parameter middleware3: Optional the third middleware applied to the route.
    public func registerDeleteRouteOpenAPI<Q: QueryParams>(route: String, queryParams: Q.Type, allOptQParams: Bool,
        middleware1: TypeSafeMiddleware.Type? = nil, middleware2: TypeSafeMiddleware.Type? = nil, middleware3: TypeSafeMiddleware.Type? = nil) {
        let middlewares = register(middleware1: middleware1, middleware2: middleware2, middleware3: middleware3)

        do {
            let querySchema = try OpenAPI.Schema(from: queryParams)
            let pathItem = OpenAPI.PathItem(
                delete: OpenAPI.Operation(
                    summary: "Delete a resource",
                    responses: [
                        "\(HTTPStatusCode.OK.rawValue)": OpenAPI.Response(
                            description: "OK"),
                        "\(HTTPStatusCode.notFound.rawValue)": OpenAPI.Response(
                                description: "Not found"),
                    ],
                    parameters: OpenAPI.Parameter.query(from: querySchema)
                        + middlewares.parameters,
                    security: middlewares.security,
                    tags: self.openapi.tagNames,
                    servers: self.openapi.servers
                )
            )
            self.openapi.add(path: pathItem, for: route)
        } catch let error {
            Log.error("Cannot register the route Delete \(route): \(error)")
        }
    }

    /// Register DELETE route
    ///
    /// - Parameter route: The route to register.
    /// - Parameter id: The id type.
    /// - Parameter middleware1: Optional the first middleware applied to the route.
    /// - Parameter middleware2: Optional the second middleware applied to the route.
    /// - Parameter middleware3: Optional the third middleware applied to the route.
    public func registerDeleteRouteOpenAPI<Id: Identifier>(
        route: String, id: Id.Type,
        middleware1: TypeSafeMiddleware.Type? = nil, middleware2: TypeSafeMiddleware.Type? = nil, middleware3: TypeSafeMiddleware.Type? = nil) {
        let middlewares = register(middleware1: middleware1, middleware2: middleware2, middleware3: middleware3)

        let idSchema = OpenAPI.Schema(plain: id)
        let pathItem = OpenAPI.PathItem(
            delete: OpenAPI.Operation(
                summary: "Delete a resource from its id",
                responses: [
                    "\(HTTPStatusCode.OK.rawValue)": OpenAPI.Response(
                        description: "OK"),
                    "\(HTTPStatusCode.notFound.rawValue)": OpenAPI.Response(
                            description: "Not found"),
                ],
                parameters: [
                        OpenAPI.Parameter(
                            name: "id",
                            in: .path,
                            content: ("id", OpenAPI.Media(schema: idSchema)),
                            description: "The id of the ressource",
                            required: true)
                    ] + middlewares.parameters,
                security: middlewares.security,
                    tags: self.openapi.tagNames,
                    servers: self.openapi.servers
            )
        )
        self.openapi.add(path: pathItem, for: route)
    }
}

extension KeyedEncodingContainer where Key: CodingKey {
    mutating func `if`<T: Encodable>(_ field: T?, forKey key: Key) throws {
        if let field = field {
            try self.encode(field, forKey: key)
        }
    }

    mutating func `if`<T: Encodable>(_ field: [T], forKey key: Key) throws {
        if field.isEmpty == false {
            try self.encode(field, forKey: key)
        }
    }
    
    mutating func `if`<DictionaryKey: Encodable, DictionaryValue: Encodable>(_ field: Dictionary<DictionaryKey, DictionaryValue>, forKey key: Key) throws {
        if field.isEmpty == false {
            try self.encode(field, forKey: key)
        }
    }
}