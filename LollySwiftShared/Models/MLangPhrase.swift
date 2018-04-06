//
//  MLangPhrase.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/07.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

import ObjectMapper

@objcMembers
class MLangPhrase: NSObject, Mappable {
    var ID = 0
    var LANGID = 0
    var PHRASE = ""
    var TRANSLATION: String?
    
    public override init() {
    }
    
    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        ID <- map["ID"]
        LANGID <- map["LANGID"]
        PHRASE <- map["PHRASE"]
        TRANSLATION <- map["TRANSLATION"]
    }
    
    static func getDataByLang(_ langid: Int, complete: @escaping ([MLangPhrase]) -> Void) {
        // SQL: SELECT PHRASE, TRANSLATION FROM LANGPHRASES WHERE LANGID = ?
        let url = "\(RestApi.url)LANGPHRASES?transform=1&filter=LANGID,eq,\(langid)"
        RestApi.getArray(url: url, keyPath: "LANGPHRASES", complete: complete)
    }
    
    static func update(_ id: Int, m: MLangPhraseEdit, complete: @escaping (String) -> Void) {
        // SQL: UPDATE LANGPHRASES SET PHRASE=?, TRANSLATION=? WHERE ID=?
        let url = "\(RestApi.url)LANGPHRASES/\(id)"
        RestApi.update(url: url, body: m.toJSONString(prettyPrint: false)!, complete: complete)
    }
    
    static func create(m: MLangPhraseEdit, complete: @escaping (String) -> Void) {
        // SQL: INSERT INTO LANGPHRASES (LANGID, PHRASE, TRANSLATION) VALUES (?,?,?)
        let url = "\(RestApi.url)LANGPHRASES"
        RestApi.create(url: url, body: m.toJSONString(prettyPrint: false)!, complete: complete)
    }
    
    static func delete(_ id: Int, complete: @escaping (String) -> Void) {
        // SQL: DELETE LANGPHRASES WHERE ID=?
        let url = "\(RestApi.url)LANGPHRASES/\(id)"
        RestApi.delete(url: url, complete: complete)
    }
}

class MLangPhraseEdit: Mappable {
    var LANGID = 0
    var PHRASE = ""
    var TRANSLATION: String?

    public init(m: MLangPhrase) {
        LANGID = m.LANGID
        PHRASE = m.PHRASE
        TRANSLATION = m.TRANSLATION
    }
    
    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        LANGID <- map["LANGID"]
        PHRASE <- map["PHRASE"]
        TRANSLATION <- map["TRANSLATION"]
    }
}
