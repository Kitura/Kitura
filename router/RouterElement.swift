//
//  RouteElement.swift
//  router
//
//  Created by Samuel Kallner on 11/4/15.
//  Copyright © 2015 IBM. All rights reserved.
//

import regex
import sys

import Foundation

class RouterElement {
    static let keyRegex = Regex()
    static let nonKeyRegex = Regex()
    static var regexInit: Int = 0
    
    private let method: RouterMethod
    private let pattern: String?
    private var regex: Regex?
    private var keys:[String]?
    
    private var handler: RouterHandler?
    private var middleware: RouterMiddleware?
    
    private init(method: RouterMethod, pattern: String?) {
        self.method = method
        self.pattern = pattern
        self.regex = nil
        self.keys = nil
        self.handler = nil
        self.middleware = nil
        
        SysUtils.doOnce(&RouterElement.regexInit) {
            RouterElement.keyRegex.compile("(.*)?(?:\\:(\\w+)(?:\\(((?:\\\\.|[^()])+)\\))?(?:([+*?])?))")
            RouterElement.nonKeyRegex.compile("(.*)?(?:(?:\\(((?:\\\\.|[^()])+)\\))(?:([+*?])?))")
        }
        
        // Needs to be after the initialization of the static Regex's
        (regex, keys) = buildRegexFromPattern(pattern)
    }
    
    convenience init(method: RouterMethod, pattern: String? , handler: RouterHandler) {
        self.init(method: method, pattern: pattern)
        
        self.handler = handler
    }
    
    convenience init(method: RouterMethod, pattern: String?, middleware: RouterMiddleware) {
        self.init(method: method, pattern: pattern)
        
        self.middleware = middleware
    }
    
    func process(httpMethod: RouterMethod, urlPath: NSData, request: RouterRequest, response: RouterResponse, next: (processed: Bool) -> Void) {
        
        if  method == .All  ||  method == httpMethod {
            if  let r = regex  {
                let matcher = r.matcher!
                if  matcher.match(urlPath) {
                    request.route = pattern
                    updateRequestParams(matcher, request: request)
                    processHelper(request, response: response, next: next)
                }
            }
            else {
                request.route = pattern
                request.params = [:]
                processHelper(request, response: response, next: next)
            }
        }
        next(processed: false)
    }
    
    private func processHelper(request: RouterRequest, response: RouterResponse, next: (processed: Bool) -> Void) {
        
        if  let handler = handler  {
            handler(request: request, response: response) { () in
                request.params = [:]
                next(processed: true)
            }
        }
        else if  let middleware = middleware  {
            middleware.handle(request, response: response) { () in
                request.params = [:]
                next(processed: true)
            }
        }

    }
    
    private func buildRegexFromPattern(pattern: String?) -> (Regex?, [String]?) {
        if  let p = pattern  {
            let keyMatcher = RouterElement.keyRegex.matcher!
            let nonKeyMatcher = RouterElement.nonKeyRegex.matcher!
            
            var regexStr = "^"
            var keys: [String] = []
            var nonKeyIndex = 0
            
            let paths = p.bridge().componentsSeparatedByString("/")
            
            for path in paths {
                // If there was a leading slash, there will be an empty component in the split
                if  path.characters.count > 0  {
                    var matched = false
                    var prefix: String = ""
                    var matchExp: String?
                    
                    if  path == "*"  {
                        // Handle a path element of * specially
                        matchExp = ".*"
                        matched = true
                    }
                    else {
                        //var plusQuestStar: String?
                        if  keyMatcher.match(path)  {
                            // We found a path element with a named/key capture
                            if  let pathPrefix = keyMatcher.getMatchedElement(1)  {
                                prefix = pathPrefix
                            }
                            matchExp = keyMatcher.getMatchedElement(3)
                            if  matchExp?.characters.count == 0  {
                                matchExp = "[^/]+?"
                            }
                            //plusQuestStar = keyMatcher.getMatchedElement(4)!
                            keys.append(keyMatcher.getMatchedElement(2)!)
                            matched = true
                        }
                        else if  nonKeyMatcher.match(path) {
                            // We found a path element with an unnamed capture
                            if  let pathPrefix = nonKeyMatcher.getMatchedElement(1)  {
                                prefix = pathPrefix
                            }
                            matchExp = nonKeyMatcher.getMatchedElement(2)!
                            //plusQuestStar = nonKeyMatcher.getMatchedElement(3)!
                            keys.append(String(nonKeyIndex))
                            nonKeyIndex+=1
                            matched = true
                        }
                    }
                
                    if  matched  {
                        // We have some kind of capture for this path element
                        regexStr.appendContentsOf("/")
                        regexStr.appendContentsOf(prefix)
                        
                        regexStr.appendContentsOf("(?:(")
                        regexStr.appendContentsOf(matchExp!)
                        regexStr.appendContentsOf("))")
                    }
                    else {
                        // A path element with no capture
                        regexStr.appendContentsOf("/")
                        regexStr.appendContentsOf(path)
                    }
                }
            }
            regexStr.appendContentsOf("?(?:/)?$")
            
            var regex: Regex? = Regex()
            if  !regex!.compile(regexStr) {
                regex = nil
            }
            
            return (regex, keys)
        }
        else {
            return (nil, nil)
        }
    }
    
    private func updateRequestParams(matcher: RegexMatcher, request: RouterRequest) {
        if  let k = keys {
            var params: [String:String] = [:]
            for index in 0..<k.count {
                params[k[index]] = matcher.getMatchedElement(index+1)
            }
            request.params = params
        }
    }
}

enum RouterMethod :Int {
    case All, Get, Post, Put, Delete, Head, Unknown
    
    
    init(string: String) {
        switch string.lowercaseString {
            case "all":
                self = .All
                break
            case "get":
                self = .Get
                break
            case "post":
                self = .Post
                break
            case "put":
                self = .Put
                break
            case "delete":
                self = .Delete
                break
            case "head":
                self = .Head
            default:
                self = .Unknown
        }
    }
}

public typealias RouterHandler = (request: RouterRequest, response: RouterResponse, next: ()->Void) -> Void
