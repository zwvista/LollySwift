//
//  Common.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2018/11/03.
//  Copyright © 2018 趙 偉. All rights reserved.
//

import Foundation
import Regex

enum DictWebViewStatus {
    case ready
    case navigating
    case automating
}

class CommonApi {
    static private let debugExtract = false
    
    static func extractText(from html: String, transform: String, template: String, templateHandler: (String, String) -> String) -> String {
        let dic = ["<delete>": "", "\\t": "\t", "\\r": "\r", "\\n": "\n"]
        var transform = transform, template = template
        let logPath = "/Users/bestskip/Documents/zw/Log/"
        if debugExtract {
            transform = try! String(contentsOfFile: logPath + "1_transform.txt", encoding: .utf8)
            template = try! String(contentsOfFile: logPath + "5_template.txt", encoding: .utf8)
            let rawStr = html.replacingOccurrences(of: "\r", with: "\\r")
            do {
                try rawStr.write(toFile: logPath + "0_raw.html", atomically: false, encoding: .utf8)
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
            var regex = arr[0].r!
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
                    try text.write(toFile: logPath + "2_extracted.txt", atomically: false, encoding: .utf8)
                } catch _ {
                }
            }
            
            for i in 2 ..< arr.count {
                if i % 2 == 0 {
                    regex = arr[i].r!
                } else {
                    f(arr[i])
                }
            }
            if debugExtract {
                do {
                    try text.write(toFile: logPath + "4_cooked.txt", atomically: false, encoding: .utf8)
                } catch _ {
                }
            }
            
            if template.isEmpty {break}
            text = templateHandler(text, template)
            
        } while false
        
        if debugExtract {
            do {
                try text.write(toFile: logPath + "6_result.html", atomically: false, encoding: .utf8)
            } catch _ {
            }
        } else {
            print(text)
        }
        
        return text
    }
}
