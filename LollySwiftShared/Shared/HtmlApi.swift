//
//  HtmlApi.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2017/06/24.
//  Copyright © 2017年 趙 偉. All rights reserved.
//

import Foundation

class HtmlApi {
    static private let debugExtract = false
    
    static func extractText(from html: String, transform: String, template: String, templateHandler: (NSMutableString, String) -> NSMutableString) -> String {
        let dic = ["<delete>": "", "\\t": "\t", "\\r": "\r", "\\n": "\n"]
        var transform = transform, template = template
        let logPath = "/Users/bestskip/Documents/zw/Log/"
        if debugExtract {
            transform = (try! NSString(contentsOfFile: logPath + "1_transform.txt", encoding: String.Encoding.utf8.rawValue)) as String
            template = (try! NSString(contentsOfFile: logPath + "5_template.txt", encoding: String.Encoding.utf8.rawValue)) as String
            let rawStr = html.replacingOccurrences(of: "\r", with: "\\r")
            do {
                try rawStr.write(toFile: logPath + "0_raw.html", atomically: true, encoding: String.Encoding.utf8)
            } catch _ {
            }
        } else {
            print(transform)
        }
        
        var text = NSMutableString()
        
        repeat {
            if transform.isEmpty {break}
            let arr = transform.components(separatedBy: "\r\n")
            var regex = try! NSRegularExpression(pattern: arr[0])
            let m = regex.firstMatch(in: html, range: NSMakeRange(0, html.count))
            if m == nil {break}
            text = NSMutableString(string: (html as NSString).substring(with: m!.range))
            
            func f(_ replacer: String) {
                var replacer = replacer
                for (key, value) in dic {
                    replacer = replacer.replacingOccurrences(of: key, with: value)
                }
                regex.replaceMatches(in: text, range: NSMakeRange(0, text.length), withTemplate: replacer)
            }
            
            f(arr[1])
            if debugExtract {
                do {
                    try text.write(toFile: logPath + "2_extracted.txt", atomically: true, encoding: String.Encoding.utf8.rawValue)
                } catch _ {
                }
            }
            
            for i in 2 ..< arr.count {
                if i % 2 == 0 {
                    regex = try! NSRegularExpression(pattern: arr[i])
                } else {
                    f(arr[i])
                }
            }
            if debugExtract {
                do {
                    try text.write(toFile: logPath + "4_cooked.txt", atomically: true, encoding: String.Encoding.utf8.rawValue)
                } catch _ {
                }
            }
            
            if template.isEmpty {break}
            text = templateHandler(text, template)
            
        } while false
        
        if debugExtract {
            do {
                try text.write(toFile: logPath + "6_result.html", atomically: true, encoding: String.Encoding.utf8.rawValue)
            } catch _ {
            }
        } else {
            print(text)
        }
        
        return text as String
    }
}
