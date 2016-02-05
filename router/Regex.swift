//
//  Regex.swift
//  icu
//
//  Created by Samuel Kallner on 10/22/15.
//  Copyright © 2015 IBM. All rights reserved.
//

import sys
import pcre2

import Foundation

public class Regex {
    
    let COMPILE_ERROR_BASE: Int32 = 100
    
    private var compiledExpr: COpaquePointer = nil
    
    public init() {}
    
    deinit {
        free()
    }
    
    public var matcher: RegexMatcher? {
        return compiledExpr != nil ? RegexMatcher(expr: compiledExpr) : nil
    }
    
    public func compile(exprSrc: String) -> Bool {
        var result = true
        
        if  let cSrc = StringUtils.toUtf8String(exprSrc)  {
            var errorCode: Int32 = 0
            var errorOffset = 0
        
            compiledExpr = pcre2_compile_8(UnsafePointer<UInt8>(cSrc.bytes), cSrc.length, PCRE2_UTF, &errorCode, &errorOffset, nil)
       
            if errorCode >= COMPILE_ERROR_BASE {
                errorCode -= COMPILE_ERROR_BASE
            
                if  errorCode != 0 {
                    result = false
                    free()
                }
            }
        }
        else {
            result = false
        }
        
        return result
    }
    
    public func free() {
        if  compiledExpr != nil {
            pcre2_code_free_8(compiledExpr)
            compiledExpr = nil
        }
    }
}
