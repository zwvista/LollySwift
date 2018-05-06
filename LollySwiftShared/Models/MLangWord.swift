//
//  MLangWord.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

import ObjectMapper

@objcMembers
class MLangWord: NSObject, Mappable {
    var ID = 0
    var LANGID = 0
    var WORD = ""
    var LEVEL = 0
    
    public override init() {
    }

    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        ID <- map["ID"]
        LANGID <- map["LANGID"]
        WORD <- map["WORD"]
        LEVEL <- map["LEVEL"]
    }
    
    static func getDataByLang(_ langid: Int, complete: @escaping ([MLangWord]) -> Void) {
        // SQL: SELECT LANGID, WORD FROM LANGWORDS WHERE LANGID = ?
        let url = "\(RestApi.url)LANGWORDS?transform=1&filter=LANGID,eq,\(langid)"
        RestApi.getArray(url: url, keyPath: "LANGWORDS", complete: complete)
    }
    
    static func update(_ id: Int, word: String, complete: @escaping (String) -> Void) {
        // SQL: UPDATE LANGWORDS SET WORD=? WHERE ID=?
        let url = "\(RestApi.url)LANGWORDS/\(id)"
        let body = "WORD=\(word)"
        RestApi.update(url: url, body: body, complete: complete)
    }
    
    static func create(item: MLangWordEdit, complete: @escaping (String) -> Void) {
        // SQL: INSERT INTO LANGWORDS (LANGID, WORD) VALUES (?,?)
        let url = "\(RestApi.url)LANGWORDS"
        RestApi.create(url: url, body: item.toJSONString(prettyPrint: false)!, complete: complete)
    }
    
    static func delete(_ id: Int, complete: @escaping (String) -> Void) {
        // SQL: DELETE LANGWORDS WHERE ID=?
        let url = "\(RestApi.url)LANGWORDS/\(id)"
        RestApi.delete(url: url, complete: complete)
    }
}

class MLangWordEdit: Mappable {
    var LANGID = 0
    var WORD = ""
    var LEVEL = 0

    public init(item: MLangWord) {
        LANGID = item.LANGID
        WORD = item.WORD
        LEVEL = item.LEVEL
    }
    
    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        LANGID <- map["LANGID"]
        WORD <- map["WORD"]
        LEVEL <- map["LEVEL"]
    }
}
