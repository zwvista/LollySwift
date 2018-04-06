//
//  MDictionary.swift
//  LollySwiftShared
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation

import ObjectMapper

@objcMembers
class MDictionary: NSObject, Mappable {
    var ID = 0
    var LANGIDFROM: Int?
    var DICTTYPENAME: String?
    var DICTNAME: String?
    var URL: String?
    var CHCONV: String?
    var TRANSFORM_MAC: String?
    var TEMPLATE: String?
    
    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        ID <- map["ID"]
        LANGIDFROM <- map["LANGIDFROM"]
        DICTTYPENAME <- map["DICTTYPENAME"]
        DICTNAME <- map["DICTNAME"]
        URL <- map["URL"]
        CHCONV <- map["CHCONV"]
        TRANSFORM_MAC <- map["TRANSFORM_MAC"]
        TEMPLATE <- map["TEMPLATE"]
    }

    func urlString(_ word: String) -> String {
        var url = URL!.replacingOccurrences(of: "{0}", with: word);
        //url = url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print(url)
        return url
    }
    
    static func getDataByLang(_ langid: Int, complete: @escaping ([MDictionary]) -> Void) {
        // SQL: SELECT * FROM VDICTIONARIES WHERE LANGIDFROM = ?
        let url = "\(RestApi.url)VDICTIONARIES?transform=1&filter=LANGIDFROM,eq,\(langid)"
        RestApi.getArray(url: url, keyPath: "VDICTIONARIES", complete: complete)
    }
    
    fileprivate let debugExtract = false
    
    func htmlString(_ html: String, word: String) -> String {
        return HtmlApi.extractText(from: html, transform: TRANSFORM_MAC!, template: TEMPLATE!) { (text, template) in
            
//            var newTemplate = NSMutableString(string: template)
//            regex = try! NSRegularExpression(pattern: "\\{\\d\\}")
//            regex.replaceMatches(in: newTemplate, range: NSMakeRange(0, newTemplate.length), withTemplate: "%@")
//            text = NSMutableString(format: newTemplate, word, "", text, RestApi.cssFolder)

            var template = template.replacingOccurrences(of: "{0}", with: word)
                .replacingOccurrences(of: "{1}", with: "")
                .replacingOccurrences(of: "{2}", with: text as String)
                .replacingOccurrences(of: "{3}", with: RestApi.cssFolder)
            return NSMutableString(string: template)
        }
    }
}
