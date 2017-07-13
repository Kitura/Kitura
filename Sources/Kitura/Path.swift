import HTTP

public enum Verb: String {
    case GET = "get"
    case PUT = "put"
    case POST = "post"
    case DELETE = "delete"
    case OPTIONS = "options"
    case HEAD = "head"
    case PATCH = "patch"

    init?(_ verb: HTTPMethod) {
        switch verb {
        case .get:
            self = .GET
        case .put:
            self = .PUT
        case .post:
            self = .POST
        case .delete:
            self = .DELETE
        case .options:
            self = .OPTIONS
        case .head:
            self = .HEAD
        case .patch:
            self = .PATCH
        default:
            return nil
        }
    }
}

struct Path: Hashable {
    public var path: String
    public var verb: Verb

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    public var hashValue: Int {
        return "\(verb) - \(path)".hashValue
    }

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: Path, rhs: Path) -> Bool {
        return lhs.path == rhs.path && lhs.verb == rhs.verb
    }
    
    public init(path:String, verb:Verb) {
        self.path = path
        self.verb = verb
    }
}
