//
//  MDictAll.swift
//  LollySharedSwift
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation

public class MDictAll: NSObject {
    public var LANGID = 0
    public var DICTTYPENAME: String?
    public var DICTNAME: String?
    public var URL: String?
    public var CHCONV: String?
    public var TRANSFORM_MAC: String?
    public var TEMPLATE: String?
    
    public func urlString(word: String) -> String {
        var url = URL!.stringByReplacingOccurrencesOfString("{0}", withString: "\(word)");
        url = url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        println(url)
        return url
    }
    
    private let debugExtract = false
    
    public func htmlString(html: String, word: String) -> String {
        let dic = ["<delete>": "", "\\t": "\t", "\\r": "\r", "\\n": "\n"]
        var transform = TRANSFORM_MAC!, template = TEMPLATE!
        let logPath = "/Users/bestskip/Documents/zw/Log/"
        if debugExtract {
            transform = NSString(contentsOfFile: logPath + "1_transform.txt", encoding: NSUTF8StringEncoding, error: nil)!
            template = NSString(contentsOfFile: logPath + "5_template.txt", encoding: NSUTF8StringEncoding, error: nil)!
            let rawStr = html.stringByReplacingOccurrencesOfString("\r", withString: "\\r")
            rawStr.writeToFile(logPath + "0_raw.html", atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        } else {
            println(transform)
        }
        
        var text = NSMutableString()
        
        do {
            if transform.isEmpty {break}
            let arr = transform.componentsSeparatedByString("\n")
            var regex = NSRegularExpression(pattern: arr[0], options: NSRegularExpressionOptions.allZeros, error: nil)!
            let m = regex.firstMatchInString(html, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, countElements(html)))
            if m == nil {break}
            text = NSMutableString(string: (html as NSString).substringWithRange(m!.range))
            
            func f(var replacer: String) {
                for (key, value) in dic {
                    replacer = replacer.stringByReplacingOccurrencesOfString(key, withString: value)
                }
                regex.replaceMatchesInString(text, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, text.length), withTemplate: replacer)
            }
            
            f(arr[1])
            if debugExtract {
                text.writeToFile(logPath + "2_extracted.txt", atomically: true, encoding: NSUTF8StringEncoding, error: nil)
            }
            
            if arr.count > 2 {
                for var i = 2; i < arr.count; {
                    regex = NSRegularExpression(pattern: arr[i++], options: NSRegularExpressionOptions.allZeros, error: nil)!
                    f(arr[i++])
                }
            }
            if debugExtract {
                text.writeToFile(logPath + "4_cooked.txt", atomically: true, encoding: NSUTF8StringEncoding, error: nil)
            }
            
            if template.isEmpty {break}
            
//            var newTemplate = NSMutableString(string: template)
//            regex = NSRegularExpression(pattern: "\\{\\d\\}", options: NSRegularExpressionOptions.allZeros, error: nil)!
//            regex.replaceMatchesInString(newTemplate, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, newTemplate.length), withTemplate: "%@")
//            text = NSMutableString(format: newTemplate, word, "", text)

            template = template.stringByReplacingOccurrencesOfString("{0}", withString: "\(word)")
                .stringByReplacingOccurrencesOfString("{1}", withString: "")
                .stringByReplacingOccurrencesOfString("{2}", withString: "\(text)")
            text = NSMutableString(string: template)
        
        } while false
        
        if debugExtract {
            text.writeToFile(logPath + "6_result.html", atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        } else {
            println(text)
        }
        
        return text
    }
}
