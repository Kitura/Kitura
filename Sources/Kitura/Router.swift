import Foundation
import HTTP

extension String {
    // OpenAPI-style path parameter
    var isPathParameter: Bool {
        return self.hasPrefix("{") && self.hasSuffix("}")
    }

    var parameterName: String? {
        guard self.isPathParameter else {
            return nil
        }

        // Drop first and last characters
        return String(self[self.index(after: self.startIndex)..<self.index(before: self.endIndex)])
    }
}

// Results from parsing request URL
struct PathComponents {
    let parameters: [String: String]?
    let queries: [URLQueryItem]?
    let restOfURL: String?
}

// URL parser
// Match URL with defined path and break URL into path parameters,
// queries, and restOfURL (if defined path allows partial match)
struct URLParameterParser {
    var pathComponents: [String]
    var partialMatch: Bool

    init(path: String, partialMatch: Bool = false) {
        // Split by "/" instead of doing URL.pathComponents because
        // path string can contain parameter captures and hence is not
        // a proper URL
        pathComponents = path.components(separatedBy: "/")

        if pathComponents.first == "" {
            pathComponents.removeFirst()
        }

        if pathComponents.last == "" {
            pathComponents.removeLast()
        }

        self.partialMatch = partialMatch
    }

    func parse(_ string: String) -> PathComponents? {
        guard let url = URL(string: string) else {
            return nil
        }

        // Step 1
        // Parse URL for path parameters
        var components = url.pathComponents

        if components.first == "/" {
            components.removeFirst()
        }

        if partialMatch {
            // Request URL must have at least as many components
            // as the defined path does
            guard pathComponents.count <= components.count else {
                return nil
            }
        }
        else {
            // Request URL must have exactly as many components as
            // the defined path does
            guard pathComponents.count == components.count else {
                return nil
            }
        }

        var parameters: [String: String] = [:]

        for i in 0..<pathComponents.count {
            if let parameter = pathComponents[i].parameterName {
                // Current component in defined path is a parameter
                // Capture the component
                parameters[parameter] = components[i]
            }
            else {
                guard pathComponents[i] == components[i] else {
                    // Path does not match request URL
                    return nil
                }
            }
        }

        // Step 2
        // Parse URL for query parameters
        let queries = URLComponents(string: string)?.queryItems

        // Step 3
        // Save restOfURL if partialMatch
        var restOfURL: String? = nil

        if partialMatch {
            restOfURL = "/" + components[pathComponents.count..<components.count].joined(separator: "/")
        }

        return PathComponents(parameters: parameters, queries: queries, restOfURL: restOfURL)
    }
}

public struct Router {
    // Enum wrapper around parameter type and corresponding response creator
    enum Handler {
        case parseBody(ParameterContaining.Type, ParameterResponseCreating)
        case skipParameters(ResponseCreating)
        case skipBody(BodylessParameterContaining.Type, BodylessParameterResponseCreating)
        case serveFile(FileServer)
    }

    private var handlers: [Path: Handler] = [:]

    private var fileServer: (path: String, handler: FileServer)?

    public init() {}

    // Add a response creator that doesn't require any parameter parsing
    public mutating func add(verb: Verb, path: String, responseCreator: ResponseCreating) {
        handlers[Path(path: path, verb: verb)] = .skipParameters(responseCreator)
    }

    // Add a chunked response creator that requires parameter parsing,
    // excluding the body
    public mutating func add(verb: Verb, path: String, parameterType: BodylessParameterContaining.Type, responseCreator: BodylessParameterResponseCreating) {
        handlers[Path(path: path, verb: verb)] = .skipBody(parameterType, responseCreator)
    }

    // Add a stored response creator that requires parameter parsing,
    // including the body
    public mutating func add(verb: Verb, path: String, parameterType: ParameterContaining.Type, responseCreator: ParameterResponseCreating) {
        handlers[Path(path: path, verb: verb)] = .parseBody(parameterType, responseCreator)
    }

    // Set a file server that is used when no other defined path match
    // the request URL
    public mutating func setDefaultFileServer(_ fileServer: FileServer, atPath: String) {
        self.fileServer = (atPath, fileServer)
    }

    // Given an HTTPRequest, find the request handler
    func route(request: HTTPRequest) -> (components: PathComponents?, handler: Handler)? {
        guard let verb = Verb(request.method) else {
            // Unsupported method
            return nil
        }

        // Shortcut for exact match
        let exactPath = Path(path: request.target, verb: verb)

        if let exactMatch = handlers[exactPath] {
            return (nil, exactMatch)
        }

        // Search map of routes for a matching handler
        for (path, match) in handlers {
            if verb == path.verb,
                let components = URLParameterParser(path: path.path).parse(request.target) {
                    return (components, match)
            }
        }

        // No match found
        // Check file server
        if let fileServer = fileServer,
            let components = URLParameterParser(path: fileServer.path, partialMatch: true).parse(request.target) {
            // File server matches
            return (components, .serveFile(fileServer.handler))
        }

        return nil
    }
}

public struct RequestContext {
    let storage: [String: Any]

    init(dict: [String:Any] = [:]) {
        storage = dict
    }
    
    public subscript(key: String) -> Any? {
        get {
            return storage[key]
        }
    }
    
    public func adding(dict:[String:Any]) -> RequestContext {
        var newstorage = storage
        dict.forEach{ newstorage[$0] = $1 }
        return RequestContext(dict: newstorage)
    }
}
