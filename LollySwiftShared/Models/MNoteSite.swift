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
class MNoteSite: NSObject, Mappable {
    var ID = 0
    var LANGIDFROM: Int?
    var DICTTYPENAME: String?
    var DICTNAME: String?
    var URL: String?
    var CHCONV: String?
    var TRANSFORM_MAC: String?
    var WAIT: Int?
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
        WAIT <- map["WAIT"]
        TEMPLATE <- map["TEMPLATE"]
    }

    func urlString(_ word: String) -> String {
        var url = URL!.replacingOccurrences(of: "{0}", with: word);
        //url = url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print(url)
        return url
    }
    
    static func getDataByLang(_ langid: Int, complete: @escaping ([MNoteSite]) -> Void) {
        // SQL: SELECT * FROM VNOTESITES WHERE LANGIDFROM = ?
        let url = "\(RestApi.url)VNOTESITES?transform=1&filter=LANGIDFROM,eq,\(langid)"
        RestApi.getArray(url: url, keyPath: "VNOTESITES", complete: complete)
    }
    
    func htmlNote(_ html: String) -> String {
        return HtmlApi.extractText(from: html, transform: TRANSFORM_MAC!, template: "") { text,_ in return text }
    }
}
