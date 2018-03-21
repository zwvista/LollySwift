//
//  MUnitPhrase.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/07.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

import ObjectMapper

@objcMembers
class MUnitPhrase: NSObject, Mappable {
    var ID = 0
    var TEXTBOOKID: Int?
    var UNIT: Int?
    var PART: Int?
    var SEQNUM: Int?
    var PHRASE: String?
    var TRANSLATION: String?
    var UNITPART: Int?
    
    public override init() {
    }

    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        ID <- map["ID"]
        TEXTBOOKID <- map["TEXTBOOKID"]
        UNIT <- map["UNIT"]
        PART <- map["PART"]
        SEQNUM <- map["SEQNUM"]
        PHRASE <- map["PHRASE"]
        TRANSLATION <- map["TRANSLATION"]
        UNITPART <- map["UNITPART"]
    }

    static func getDataByTextbook(_ textbookid: Int, unitPartFrom: Int, unitPartTo: Int, complete: @escaping ([MUnitPhrase]) -> Void) {
        // SQL: SELECT * FROM VUNITPHRASES WHERE TEXTBOOKID=? AND UNITPART BETWEEN ? AND ? ORDER BY UNITPART,SEQNUM
        let url = "\(RestApi.url)VUNITPHRASES?transform=1&filter[]=TEXTBOOKID,eq,\(textbookid)&filter[]=UNITPART,bt,\(unitPartFrom),\(unitPartTo)&order[]=UNITPART&order[]=SEQNUM"
        RestApi.getArray(url: url, keyPath: "VUNITPHRASES", complete: complete)
    }
    
    static func update(_ id: Int, seqnum: Int, complete: @escaping (String) -> Void) {
        // SQL: UPDATE UNITPHRASES SET SEQNUM=? WHERE ID=?
        let url = "\(RestApi.url)UNITPHRASES/\(id)"
        let body = "SEQNUM=\(seqnum)"
        RestApi.update(url: url, body: body, complete: complete)
    }
    
    static func update(_ id: Int, m: MUnitPhraseEdit, complete: @escaping (String) -> Void) {
        // SQL: UPDATE UNITPHRASES SET UNIT=?, PART=?, SEQNUM=?, PHRASE=?, TRANSLATION=? WHERE ID=?
        let url = "\(RestApi.url)UNITPHRASES/\(id)"
        RestApi.update(url: url, body: m.toJSONString(prettyPrint: false)!, complete: complete)
    }
    
    static func create(m: MUnitPhraseEdit, complete: @escaping (String) -> Void) {
        // SQL: INSERT INTO UNITPHRASES (UNIT, PART, SEQNUM, PHRASE, TRANSLATION) VALUES (?,?,?,?,?)
        let url = "\(RestApi.url)UNITPHRASES"
        RestApi.create(url: url, body: m.toJSONString(prettyPrint: false)!, complete: complete)
    }
    
    static func delete(_ id: Int, complete: @escaping (String) -> Void) {
        // SQL: DELETE UNITPHRASES WHERE ID=?
        let url = "\(RestApi.url)UNITPHRASES/\(id)"
        RestApi.delete(url: url, complete: complete)
    }
}

class MUnitPhraseEdit: Mappable {
    var UNIT: Int?
    var PART: Int?
    var SEQNUM: Int?
    var PHRASE: String?
    var TRANSLATION: String?
    
    public init(m: MUnitPhrase) {
        UNIT = m.UNIT
        PART = m.PART
        SEQNUM = m.SEQNUM
        PHRASE = m.PHRASE
        TRANSLATION = m.TRANSLATION
    }
    
    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        UNIT <- map["UNIT"]
        PART <- map["PART"]
        SEQNUM <- map["SEQNUM"]
        PHRASE <- map["PHRASE"]
        TRANSLATION <- map["TRANSLATION"]
    }
}
