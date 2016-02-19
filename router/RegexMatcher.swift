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

import KituraSys
import Foundation

import pcre2

// MARK: RegexMatcher

public class RegexMatcher {

    /// 
    /// Compiled expression handle
    ///
    let compiledExpr: COpaquePointer
    
    ///
    /// Match data block in pcre2
    ///
    let matchData: COpaquePointer
    
    ///
    ///
    ///
    var matchStr: NSData?
    
    ///
    ///
    ///
    public var matchCount: Int {
        
        return matchStr != nil ? Int(pcre2_get_ovector_count_8(matchData)) : 0
        
    }
    
    ///
    /// Initializes a RegexMatcher instance
    ///
    /// - Parameter expr: pointer to the expression
    ///
    /// - Returns: instance of RegexMatcher
    ///
    init(expr: COpaquePointer) {
        
        compiledExpr = expr
        matchData = pcre2_match_data_create_from_pattern_8(compiledExpr, nil)
        
    }
    
    /// 
    /// Destroy the RegexMatcher
    ///
    deinit {
        
        pcre2_match_data_free_8(matchData)
        
    }
    
    ///
    /// Check is the given string matches the regular expression
    ///
    /// - Parameter str: the string to be matched
    ///
    /// - Returns: whether the string matched the regex 
    ///
    public func match(str: String) -> Bool {
        
        let cStr = StringUtils.toUtf8String(str)
        return cStr != nil ? match(cStr!) : false
        
    }
    
    ///
    /// Check is the given data matches the regular expression
    ///
    /// - Parameter data: the data to be matched
    ///
    /// - Returns: whether the string matched the regex
    ///
    public func match(data: NSData) -> Bool {
        
        var result = false
        matchStr = data
        
        let rc = pcre2_match_8(compiledExpr, UnsafePointer<UInt8>(matchStr!.bytes), matchStr!.length, 0, 0, matchData, nil)
        
        if  rc > 0 {
            result = true
        }
        
        return result
    }
    
    ///
    /// Return the matched elements
    /// 
    /// - Parameter number: the number elements to return 
    ///
    /// - Returns: the element 
    ///
    public func getMatchedElement(number: Int) -> String? {
        
        var result: String? = nil
        if  matchStr != nil {
            let count = pcre2_get_ovector_count_8(matchData)
            if  count >= UInt32(number) {
                let oVector = pcre2_get_ovector_pointer_8(matchData)
                let startIndex = oVector[number*2]
                let endIndex = oVector[number*2+1]
                
                result = NSString(bytes: matchStr!.bytes+startIndex, length: endIndex-startIndex, encoding: NSUTF8StringEncoding)!.bridge() as String?
            }
        }
        return result
        
    }
    
    /// 
    /// Perform string replacement
    ///
    /// - Parameter str: String
    /// - Parameter replacement: replacement String 
    /// - Parameter globally: whether to replace it globally
    ///
    /// - Returns: 
    ///
    public func substitute(str: String, replacement: String, globally: Bool=false) -> (Int, String?) {
        
        let cStr = StringUtils.toUtf8String(str)
        let cRepl = StringUtils.toUtf8String(replacement)
        if  cStr != nil  &&  cRepl != nil  {
            var resultCstr = [UInt8](count: cStr!.length*5, repeatedValue: 0)
        
            let count = substitute(cStr!, replacement: cRepl!, output: &resultCstr, globally: globally)
        
            return (Int(count), String(CString: UnsafePointer<Int8>(resultCstr), encoding: NSUTF8StringEncoding))
        }
        else {
            return (0, nil)
        }
        
    }
    
    ///
    /// Perform string replacement in data
    ///
    /// - Parameter str: data to be interpreted as a String
    /// - Parameter replacement: replacement String
    /// - Parameter globally: whether to replace it globally
    ///
    /// - Returns:
    ///

    public func substitute(str: NSData, replacement: NSData, inout output: [UInt8], globally: Bool=false) -> Int {
        
        let options:UInt32 = globally ? PCRE2_SUBSTITUTE_GLOBAL : 0
        var resultLen: size_t = output.count-1
        
        let rc = pcre2_substitute_8(compiledExpr, UnsafePointer<UInt8>(str.bytes), str.length, 0, options, matchData, nil, UnsafePointer<UInt8>(replacement.bytes), replacement.length, &output, &resultLen)
        
        return Int(rc)
        
    }
}
