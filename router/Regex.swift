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

import sys
import pcre2

import Foundation

// MARK: Regex

public class Regex {
    
    ///
    /// TODO: ???
    ///
    let COMPILE_ERROR_BASE: Int32 = 100
    
    ///
    /// Pointer to the compiled regular expression
    ///
    private var compiledExpr: COpaquePointer = nil
    
    /// 
    /// Initializes a Regex instance
    ///
    public init() {}
    
    ///
    /// Deconstructs the instance
    ///
    deinit {
        free()
    }
    
    ///
    /// Returns the Optional Regular Expression matcher
    ///
    public var matcher: RegexMatcher? {
        return compiledExpr != nil ? RegexMatcher(expr: compiledExpr) : nil
    }
    
    ///
    /// Compile the expression
    ///
    /// - Parameter exprSrc: regular expression
    /// 
    /// - Returns: whether successful 
    ///
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
    
    /// 
    /// Free the regular expression matcher
    ///
    public func free() {
        
        if  compiledExpr != nil {
            pcre2_code_free_8(compiledExpr)
            compiledExpr = nil
        }
        
    }
}
