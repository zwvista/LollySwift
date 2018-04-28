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
    var TEXTBOOKID = 0
    var UNIT = 0
    var PART = 0
    var SEQNUM = 0
    var PHRASE = ""
    var TRANSLATION: String?
    var UNITPART = 0
    
    func PARTSTR(arrParts: [String]) -> String {
        return arrParts[PART - 1]
    }
    func UNITPARTSEQNUM(arrParts: [String]) -> String {
        return "\(UNIT) \(SEQNUM)\n\(PARTSTR(arrParts: arrParts))"
    }

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
    
    static func update(m: MUnitPhrase, complete: @escaping (String) -> Void) {
        // SQL: UPDATE UNITPHRASES SET TEXTBOOKID=?, UNIT=?, PART=?, SEQNUM=?, PHRASE=?, TRANSLATION=? WHERE ID=?
        let url = "\(RestApi.url)UNITPHRASES/\(m.ID)"
        RestApi.update(url: url, body: m.toJSONString(prettyPrint: false)!, complete: complete)
    }
    
    static func create(m: MUnitPhrase, complete: @escaping (String) -> Void) {
        // SQL: INSERT INTO UNITPHRASES (TEXTBOOKID, UNIT, PART, SEQNUM, PHRASE, TRANSLATION) VALUES (?,?,?,?,?,?)
        let url = "\(RestApi.url)UNITPHRASES"
        RestApi.create(url: url, body: m.toJSONString(prettyPrint: false)!, complete: complete)
    }
    
    static func delete(_ id: Int, complete: @escaping (String) -> Void) {
        // SQL: DELETE UNITPHRASES WHERE ID=?
        let url = "\(RestApi.url)UNITPHRASES/\(id)"
        RestApi.delete(url: url, complete: complete)
    }
}
