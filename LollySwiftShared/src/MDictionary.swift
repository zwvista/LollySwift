//
//  MDictionary.swift
//  LollySwiftShared
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation

open class MDictionary: DBObject {
    open var ID = 0
    open var LANGIDFROM = 0
    open var DICTTYPENAME: String?
    open var DICTNAME: String?
    open var URL: String?
    open var CHCONV: String?
    open var TRANSFORM_MAC: String?
    open var TEMPLATE: String?
    
    open func urlString(_ word: String) -> String {
        var url = URL!.replacingOccurrences(of: "{0}", with: word);
        //url = url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print(url)
        return url
    }
    
    static func getDataByLang(_ langID: Int) -> [MDictionary] {
        let sql = "SELECT * FROM VDICTIONARIES WHERE LANGIDFROM = ?"
        let results = try! DBObject.dbCore.executeQuery(sql, langID as AnyObject)
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }
    
    fileprivate let debugExtract = false
    
    open func htmlString(_ html: String, word: String) -> String {
        let dic = ["<delete>": "", "\\t": "\t", "\\r": "\r", "\\n": "\n"]
        var transform = TRANSFORM_MAC!, template = TEMPLATE!
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
            let arr = transform.components(separatedBy: "\n")
            var regex = try! NSRegularExpression(pattern: arr[0], options: NSRegularExpression.Options())
            let m = regex.firstMatch(in: html, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, html.characters.count))
            if m == nil {break}
            text = NSMutableString(string: (html as NSString).substring(with: m!.range))
            
            func f(_ replacer: String) {
                var replacer = replacer
                for (key, value) in dic {
                    replacer = replacer.replacingOccurrences(of: key, with: value)
                }
                regex.replaceMatches(in: text, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, text.length), withTemplate: replacer)
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
                    regex = try! NSRegularExpression(pattern: arr[i], options: NSRegularExpression.Options())
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
            
//            var newTemplate = NSMutableString(string: template)
//            regex = NSRegularExpression(pattern: "\\{\\d\\}", options: NSRegularExpressionOptions.allZeros, error: nil)!
//            regex.replaceMatchesInString(newTemplate, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, newTemplate.length), withTemplate: "%@")
//            text = NSMutableString(format: newTemplate, word, "", text)

            template = template.replacingOccurrences(of: "{0}", with: word)
                .replacingOccurrences(of: "{1}", with: "")
                .replacingOccurrences(of: "{2}", with: text as String)
            text = NSMutableString(string: template)
        
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
