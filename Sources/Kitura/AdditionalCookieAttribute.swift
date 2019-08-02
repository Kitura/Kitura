import Foundation

/// Describes an optional attribute of a cookie.
public struct AdditionalCookieAttribute {
    internal enum _CookieAttribute {
        // A comment for the cookie.
        case comment(String?)
        // A URL that can be presented to the user as a link for further information about this cookie.
        case commentURL(String?)
        // A String value representing a boolean (TRUE/FALSE), stating whether the cookie should be discarded at the end of the session
        case discard(String)
        // The list of ports for the cookie,  an array of NSNumber objects containing integers.
        case expires(Date?)
        //  A boolean value that indicates whether this cookie should only be sent over secure channels.
        case isSecure(Bool)
        // A value stating how long in seconds the cookie should be kept, at most.
        case maximumAge(String)
        // The URL that set this cookie.
        case originURL(URL?)
        // The version of the cookie. Must be either 0 or 1. The default is 0.
        case portList([NSNumber]?)
        // The cookie’s expiration date. The expiration date is the date when the cookie should be deleted.
        case version(Int)
    }

    // The internal case represented by this instance of CookieAttribute.
    internal let _value: _CookieAttribute

    // Called by public API to create an internal representation.
    private init(_ value: _CookieAttribute) {
        self._value = value
    }

    /// A comment for the cookie.
    public static func comment(_ value: String?) -> AdditionalCookieAttribute {
        return AdditionalCookieAttribute(_CookieAttribute.comment(value))
    }

    /// A URL that can be presented to the user as a link for further information about this cookie.
    public static func commentURL(_ value: String?) -> AdditionalCookieAttribute {
        return AdditionalCookieAttribute(_CookieAttribute.commentURL(value))
    }

    /// A String value representing a boolean (TRUE/FALSE), stating whether the cookie should be discarded at the end of the session.
    public static func discard(_ value: String) -> AdditionalCookieAttribute {
        return AdditionalCookieAttribute(_CookieAttribute.discard(value))
    }

    /// The cookie’s expiration date. The expiration date is the date when the cookie should be deleted.
    public static func expires(_ value: Date?) -> AdditionalCookieAttribute {
        return AdditionalCookieAttribute(_CookieAttribute.expires(value))
    }

    /// A boolean value that indicates whether this cookie should only be sent over secure channels.
    public static func isSecure(_ value: Bool) -> AdditionalCookieAttribute {
        return AdditionalCookieAttribute(_CookieAttribute.isSecure(value))
    }

    /// A value stating how long in seconds the cookie should be kept, at most.
    public static func maximumAge(_ value: String) -> AdditionalCookieAttribute {
        return AdditionalCookieAttribute(_CookieAttribute.maximumAge(value))
    }

    /// The URL that set this cookie.
    public static func originURL(_ value: URL?) -> AdditionalCookieAttribute {
        return AdditionalCookieAttribute(_CookieAttribute.originURL(value))
    }

    /// The list of ports for the cookie,  an array of NSNumber objects containing integers.
    public static func portList(_ value: [NSNumber]?) -> AdditionalCookieAttribute {
        return AdditionalCookieAttribute(_CookieAttribute.portList(value))
    }

    /// The version of the cookie. Must be either 0 or 1. The default is 0.
    public static func version(_ value: Int) -> AdditionalCookieAttribute {
        return AdditionalCookieAttribute(_CookieAttribute.version(value))
    }
}
