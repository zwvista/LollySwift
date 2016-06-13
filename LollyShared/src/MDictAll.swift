//
//  MDictAll.swift
//  LollySharedSwift
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation

public class MDictAll: DBObject {
    public var LANGID = 0
    public var DICTTYPENAME: String?
    public var DICTNAME: String?
    public var URL: String?
    public var CHCONV: String?
    public var TRANSFORM_MAC: String?
    public var TEMPLATE: String?
    
    public func urlString(word: String) -> String {
        var url = URL!.stringByReplacingOccurrencesOfString("{0}", withString: word);
        //url = url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        url = url.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!
        print(url)
        return url
    }
    
    private let debugExtract = false
    
    public func htmlString(html: String, word: String) -> String {
        let dic = ["<delete>": "", "\\t": "\t", "\\r": "\r", "\\n": "\n"]
        var transform = TRANSFORM_MAC!, template = TEMPLATE!
        let logPath = "/Users/bestskip/Documents/zw/Log/"
        if debugExtract {
            transform = (try! NSString(contentsOfFile: logPath + "1_transform.txt", encoding: NSUTF8StringEncoding)) as String
            template = (try! NSString(contentsOfFile: logPath + "5_template.txt", encoding: NSUTF8StringEncoding)) as String
            let rawStr = html.stringByReplacingOccurrencesOfString("\r", withString: "\\r")
            do {
                try rawStr.writeToFile(logPath + "0_raw.html", atomically: true, encoding: NSUTF8StringEncoding)
            } catch _ {
            }
        } else {
            print(transform)
        }
        
        var text = NSMutableString()
        
        repeat {
            if transform.isEmpty {break}
            let arr = transform.componentsSeparatedByString("\n")
            var regex = try! NSRegularExpression(pattern: arr[0], options: NSRegularExpressionOptions())
            let m = regex.firstMatchInString(html, options: NSMatchingOptions(), range: NSMakeRange(0, html.characters.count))
            if m == nil {break}
            text = NSMutableString(string: (html as NSString).substringWithRange(m!.range))
            
            func f(replacer: String) {
                var replacer2 = replacer
                for (key, value) in dic {
                    replacer2 = replacer2.stringByReplacingOccurrencesOfString(key, withString: value)
                }
                regex.replaceMatchesInString(text, options: NSMatchingOptions(), range: NSMakeRange(0, text.length), withTemplate: replacer2)
            }
            
            f(arr[1])
            if debugExtract {
                do {
                    try text.writeToFile(logPath + "2_extracted.txt", atomically: true, encoding: NSUTF8StringEncoding)
                } catch _ {
                }
            }
            
            for i in 2 ..< arr.count {
                if i % 2 == 0 {
                    regex = try! NSRegularExpression(pattern: arr[i], options: NSRegularExpressionOptions())
                } else {
                    f(arr[i])
                }
            }
            if debugExtract {
                do {
                    try text.writeToFile(logPath + "4_cooked.txt", atomically: true, encoding: NSUTF8StringEncoding)
                } catch _ {
                }
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
            do {
                try text.writeToFile(logPath + "6_result.html", atomically: true, encoding: NSUTF8StringEncoding)
            } catch _ {
            }
        } else {
            print(text)
        }
        
        return text as String
    }
}
