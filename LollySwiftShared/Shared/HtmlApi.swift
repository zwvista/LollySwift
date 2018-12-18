//
//  HtmlApi.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2017/06/24.
//  Copyright © 2017年 趙 偉. All rights reserved.
//

import Foundation
import Regex

class HtmlApi {
    static private let debugExtract = false
    
    static func extractText(from html: String, transform: String, template: String, templateHandler: (String, String) -> String) -> String {
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
        
        var text = ""
        
        repeat {
            if transform.isEmpty {break}
            var arr = transform.components(separatedBy: "\r\n")
            if arr.count % 2 == 1 { arr.removeLast() }
            var regex = try! Regex(pattern: arr[0])
            let m = regex.findFirst(in: html)
            if m == nil {break}
            text = m!.matched
            
            func f(_ replacer: String) {
                var replacer = replacer
                for (key, value) in dic {
                    replacer = replacer.replacingOccurrences(of: key, with: value)
                }
                text = regex.replaceAll(in: text, with: replacer)
            }
            
            f(arr[1])
            if debugExtract {
                do {
                    try text.write(to: URL(string: logPath + "2_extracted.txt")!, atomically: true, encoding: .utf8)
                } catch _ {
                }
            }
            
            for i in 2 ..< arr.count {
                if i % 2 == 0 {
                    regex = try! Regex(pattern: arr[i])
                } else {
                    f(arr[i])
                }
            }
            if debugExtract {
                do {
                    try text.write(to: URL(string: logPath + "4_cooked.txt")!, atomically: true, encoding: .utf8)
                } catch _ {
                }
            }
            
            if template.isEmpty {break}
            text = templateHandler(text, template)
            
        } while false
        
        if debugExtract {
            do {
                try text.write(to: URL(string: logPath + "6_result.html")!, atomically: true, encoding: .utf8)
            } catch _ {
            }
        } else {
            print(text)
        }
        
        return text
    }
}
