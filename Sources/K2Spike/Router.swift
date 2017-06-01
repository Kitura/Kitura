import Foundation
import SwiftServerHttp

extension String {
    var isPathParameter: Bool {
        return self.hasPrefix("{") && self.hasSuffix("}")
    }

    var parameterName: String? {
        guard self.isPathParameter else {
            return nil
        }

        return self[self.index(after: self.startIndex)..<self.index(before: self.endIndex)]
    }
}

struct PathComponents {
    let parameters: [String: String]?
    let queries: [URLQueryItem]?
}

struct URLParameterParser {
    var pathComponents: [String]

    init(path: String) {
        pathComponents = path.components(separatedBy: "/")

        if pathComponents.first == "" {
            pathComponents.removeFirst()
        }
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

        guard pathComponents.count == components.count else {
            return nil
        }

        var parameters: [String: String] = [:]

        for i in 0..<pathComponents.count {
            if let parameter = pathComponents[i].parameterName {
                parameters[parameter] = components[i]
            }
            else {
                guard pathComponents[i] == components[i] else {
                    // path does not match
                    return nil
                }
            }
        }

        // Step 2
        // Parse URL for query parameters
        let queries = URLComponents(string: string)?.queryItems

        return PathComponents(parameters: parameters, queries: queries)
    }
}

public struct Router {
    // Enum wrapper around parameter type and corresponding response creator
    enum Handler {
        case parseBody(ParameterContaining.Type, ParameterResponseCreating)
        case skipParameters(ResponseCreating)
        case skipBody(BodylessParameterContaining.Type, BodylessParameterResponseCreating)
    }

    private var map: [Path: Handler] = [:]

    // Add a response creator that doesn't require any parameter parsing
    public mutating func add(verb: Verb, path: String, responseCreator: ResponseCreating) {
        map[Path(path: path, verb: verb)] = .skipParameters(responseCreator)
    }

    // Add a chunked response creator that requires parameter parsing, excluding the body
    public mutating func add(verb: Verb, path: String, parameterType: BodylessParameterContaining.Type, responseCreator: BodylessParameterResponseCreating) {
        map[Path(path: path, verb: verb)] = .skipBody(parameterType, responseCreator)
    }

    // Add a stored response creator that requires parameter parsing, including the body
    public mutating func add(verb: Verb, path: String, parameterType: ParameterContaining.Type, responseCreator: ParameterResponseCreating) {
        map[Path(path: path, verb: verb)] = .parseBody(parameterType, responseCreator)
    }

    // Given an HTTPRequest, find the request handler
    func route(request: HTTPRequest) -> (components: PathComponents?, handler: Handler)? {
        guard let verb = Verb(request.method) else {
            return nil
        }

        //shortcut for exact match
        let exactPath = Path(path: request.target, verb: verb)

        if let exactMatch = map[exactPath] {
            return (nil, exactMatch)
        }

        for (path, match) in map {
            guard verb == path.verb,
                let components = URLParameterParser(path: path.path).parse(request.target) else {
                    continue
            }

            return (components, match)
        }
        
        return nil
    }
}

public struct RequestContext {
    let storage: [String: Any]

    init(dict:[String:Any]) {
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
