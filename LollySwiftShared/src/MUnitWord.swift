//
//  MUnitWord.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/06/25.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

import ObjectMapper

@objcMembers
class MUnitWord: NSObject, Mappable {
    var ID = 0
    var TEXTBOOKID: Int?
    var UNIT: Int?
    var PART: Int?
    var SEQNUM: Int?
    var WORD: String?
    var NOTE: String?
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
        WORD <- map["WORD"]
        NOTE <- map["NOTE"]
        UNITPART <- map["UNITPART"]
    }

    static func getDataByTextbook(_ textbookid: Int, unitPartFrom: Int, unitPartTo: Int, complete: @escaping ([MUnitWord]) -> Void) {
        // SQL: SELECT * FROM VUNITWORDS WHERE TEXTBOOKID=? AND UNITPART BETWEEN ? AND ? ORDER BY UNITPART,SEQNUM
        let url = "\(RestApi.url)VUNITWORDS?transform=1&filter[]=TEXTBOOKID,eq,\(textbookid)&filter[]=UNITPART,bt,\(unitPartFrom),\(unitPartTo)&order[]=UNITPART&order[]=SEQNUM"
        RestApi.getArray(url: url, keyPath: "VUNITWORDS", complete: complete)
    }
    
    static func update(_ id: Int, seqnum: Int, complete: @escaping (String) -> Void) {
        // SQL: UPDATE UNITWORDS SET SEQNUM=? WHERE ID=?
        let url = "\(RestApi.url)UNITWORDS/\(id)"
        let body = "SEQNUM=\(seqnum)"
        RestApi.update(url: url, body: body, complete: complete)
    }
    
    static func update(_ id: Int, m: MUnitWordEdit, complete: @escaping (String) -> Void) {
        // SQL: UPDATE UNITWORDS SET UNIT=?, PART=?, SEQNUM=?, WORD=?, NOTE=? WHERE ID=?
        let url = "\(RestApi.url)UNITWORDS/\(id)"
        RestApi.update(url: url, body: m.toJSONString(prettyPrint: false)!, complete: complete)
    }
    
    static func create(m: MUnitWordEdit, complete: @escaping (String) -> Void) {
        // SQL: INSERT INTO UNITWORDS (UNIT, PART, SEQNUM, WORD, NOTE) VALUES (?,?,?,?,?)
        let url = "\(RestApi.url)UNITWORDS"
        RestApi.create(url: url, body: m.toJSONString(prettyPrint: false)!, complete: complete)
    }
    
    static func delete(_ id: Int, complete: @escaping (String) -> Void) {
        // SQL: DELETE UNITWORDS WHERE ID=?
        let url = "\(RestApi.url)UNITWORDS/\(id)"
        RestApi.delete(url: url, complete: complete)
    }
}

class MUnitWordEdit: Mappable {
    var UNIT: Int?
    var PART: Int?
    var SEQNUM: Int?
    var WORD: String?
    var NOTE: String?
    
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
