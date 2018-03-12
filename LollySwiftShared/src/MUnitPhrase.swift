//
//  MUnitPhrase.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/07.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

import ObjectMapper

open class MUnitPhrase: Mappable {
    open var ID: Int? = 0
    open var TEXTBOOKID: Int?
    open var UNIT: Int?
    open var PART: Int?
    open var SEQNUM: Int?
    open var PHRASE: String?
    open var TRANSLATION: String?
    open var UNITPART: Int?
    
    public init() {
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

    static func getDataByTextbook(_ textbookid: Int, unitPartFrom: Int, unitPartTo: Int, completionHandler: @escaping ([MUnitPhrase]) -> Void) {
        // let sql = "SELECT * FROM VUNITPHRASES WHERE TEXTBOOKID=? AND UNITPART BETWEEN ? AND ? ORDER BY UNITPART,SEQNUM"
        let url = "\(RestApi.url)VUNITPHRASES?transform=1&filter[]=TEXTBOOKID,eq,\(textbookid)&filter[]=UNITPART,bt,\(unitPartFrom),\(unitPartTo)&order[]=UNITPART&order[]=SEQNUM"
        RestApi.getArray(url: url, keyPath: "VUNITPHRASES", completionHandler: completionHandler)
    }
    
    static func update(_ id: Int, seqnum: Int, completionHandler: @escaping (String) -> Void) {
        // let sql = "UPDATE UNITPHRASES SET SEQNUM=? WHERE ID=?"
        let url = "\(RestApi.url)UNITPHRASES/\(id)"
        let body = "SEQNUM=\(seqnum)"
        RestApi.update(url: url, body: body, completionHandler: completionHandler)
    }
    
    static func update(_ id: Int, m: MUnitPhraseEdit, completionHandler: @escaping (String) -> Void) {
        // let sql = "UPDATE UNITPHRASES SET UNIT=?, PART=?, SEQNUM=?, PHRASE=?, TRANSLATION=? WHERE ID=?"
        let url = "\(RestApi.url)UNITPHRASES/\(id)"
        RestApi.update(url: url, body: m.toJSONString(prettyPrint: false)!, completionHandler: completionHandler)
    }
    
    static func create(m: MUnitPhraseEdit, completionHandler: @escaping (String) -> Void) {
        // let sql = "INSERT INTO UNITPHRASES (ID, UNIT, PART, SEQNUM, PHRASE, TRANSLATION) VALUES (?,?,?,?,?,?)"
        let url = "\(RestApi.url)UNITPHRASES"
        RestApi.create(url: url, body: m.toJSONString(prettyPrint: false)!, completionHandler: completionHandler)
    }
    
    static func delete(_ id: Int, completionHandler: @escaping (String) -> Void) {
        // let sql = "DELETE UNITPHRASES WHERE ID=?"
        let url = "\(RestApi.url)UNITPHRASES/\(id)"
        RestApi.delete(url: url, completionHandler: completionHandler)
    }
}

open class MUnitPhraseEdit: Mappable {
    open var UNIT: Int?
    open var PART: Int?
    open var SEQNUM: Int?
    open var PHRASE: String?
    open var TRANSLATION: String?
    
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
