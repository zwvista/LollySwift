//
//  MUnitWord.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/06/25.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

import ObjectMapper

open class MUnitWord: Mappable {
    open var ID: Int? = 0
    open var TEXTBOOKID: Int?
    open var UNIT: Int?
    open var PART: Int?
    open var SEQNUM: Int?
    open var WORD: String?
    open var NOTE: String?
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
        WORD <- map["WORD"]
        NOTE <- map["NOTE"]
        UNITPART <- map["UNITPART"]
    }

    static func getDataByTextbook(_ textbookid: Int, unitPartFrom: Int, unitPartTo: Int, completionHandler: @escaping ([MUnitWord]) -> Void) {
        // let sql = "SELECT * FROM VUNITWORDS WHERE TEXTBOOKID=? AND UNITPART BETWEEN ? AND ? ORDER BY UNITPART,SEQNUM"
        let url = "\(RestApi.url)VUNITWORDS?transform=1&filter[]=TEXTBOOKID,eq,\(textbookid)&filter[]=UNITPART,bt,\(unitPartFrom),\(unitPartTo)&order[]=UNITPART&order[]=SEQNUM"
        RestApi.getArray(url: url, keyPath: "VUNITWORDS", completionHandler: completionHandler)
    }
    
    static func update(_ id: Int, seqnum: Int, completionHandler: @escaping (String) -> Void) {
        // let sql = "UPDATE UNITWORDS SET SEQNUM=? WHERE ID=?"
        let url = "\(RestApi.url)UNITWORDS/\(id)"
        let body = "SEQNUM=\(seqnum)"
        RestApi.update(url: url, body: body, completionHandler: completionHandler)
    }
    
    static func update(_ id: Int, m: MUnitWordEdit, completionHandler: @escaping (String) -> Void) {
        // let sql = "UPDATE UNITWORDS SET UNIT=?, PART=?, SEQNUM=?, WORD=?, NOTE=? WHERE ID=?"
        let url = "\(RestApi.url)UNITWORDS/\(id)"
        RestApi.update(url: url, body: m.toJSONString(prettyPrint: false)!, completionHandler: completionHandler)
    }
    
    static func create(m: MUnitWordEdit, completionHandler: @escaping (String) -> Void) {
        // let sql = "INSERT INTO UNITWORDS (ID, UNIT, PART, SEQNUM, WORD, NOTE) VALUES (?,?,?,?,?,?)"
        let url = "\(RestApi.url)UNITWORDS"
        RestApi.create(url: url, body: m.toJSONString(prettyPrint: false)!, completionHandler: completionHandler)
    }
    
    static func delete(_ id: Int, completionHandler: @escaping (String) -> Void) {
        // let sql = "DELETE UNITWORDS WHERE ID=?"
        let url = "\(RestApi.url)UNITWORDS/\(id)"
        RestApi.delete(url: url, completionHandler: completionHandler)
    }
}

open class MUnitWordEdit: Mappable {
    open var UNIT: Int?
    open var PART: Int?
    open var SEQNUM: Int?
    open var WORD: String?
    open var NOTE: String?
    
    public init(m: MUnitWord) {
        UNIT = m.UNIT
        PART = m.PART
        SEQNUM = m.SEQNUM
        WORD = m.WORD
        NOTE = m.NOTE
    }
    
    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        UNIT <- map["UNIT"]
        PART <- map["PART"]
        SEQNUM <- map["SEQNUM"]
        WORD <- map["WORD"]
        NOTE <- map["NOTE"]
    }
}
