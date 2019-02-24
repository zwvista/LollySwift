//
//  MUnitPhrase.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/07.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
class MUnitPhrase: NSObject, Codable {
    var ID = 0
    var LANGID = 0
    var TEXTBOOKID = 0
    var UNIT = 0
    var PART = 0
    var SEQNUM = 0
    var PHRASEID = 0
    var PHRASE = ""
    var TRANSLATION: String?
    
    func UNITSTR(arrUnits: [String]) -> String {
        return arrUnits[UNIT - 1]
    }
    func PARTSTR(arrParts: [String]) -> String {
        return arrParts[PART - 1]
    }
    func UNITPARTSEQNUM(arrUnits: [String], arrParts: [String]) -> String {
        return "\(UNITSTR(arrUnits: arrUnits)) \(SEQNUM)\n\(PARTSTR(arrParts: arrParts))"
    }

    static func getDataByTextbook(_ textbookid: Int, unitPartFrom: Int, unitPartTo: Int) -> Observable<[MUnitPhrase]> {
        // SQL: SELECT * FROM VUNITPHRASES WHERE TEXTBOOKID=? AND UNITPART BETWEEN ? AND ? ORDER BY UNITPART,SEQNUM
        let url = "\(RestApi.url)VUNITPHRASES?transform=1&filter[]=TEXTBOOKID,eq,\(textbookid)&filter[]=UNITPART,bt,\(unitPartFrom),\(unitPartTo)&order[]=UNITPART&order[]=SEQNUM"
        return RestApi.getArray(url: url, keyPath: "VUNITPHRASES")
    }
    
    static func getDataByLangPhrase(_ phraseid: Int) -> Observable<[MUnitPhrase]> {
        // SQL: SELECT * FROM VUNITPHRASES WHERE PHRASEID=?
        let url = "\(RestApi.url)VUNITPHRASES?filter=PHRASEID,eq,\(phraseid)"
        return RestApi.getArray(url: url, keyPath: "VUNITPHRASES")
    }

    static func update(_ id: Int, seqnum: Int) -> Observable<()> {
        // SQL: UPDATE UNITPHRASES SET SEQNUM=? WHERE ID=?
        let url = "\(RestApi.url)UNITPHRASES/\(id)"
        let body = "SEQNUM=\(seqnum)"
        return RestApi.update(url: url, body: body).map { print($0) }
    }
    
    static func update(item: MUnitPhrase) -> Observable<()> {
        // SQL: UPDATE UNITPHRASES SET UNIT=?, PART=?, SEQNUM=?, PHRASEID=? WHERE ID=?
        let url = "\(RestApi.url)UNITPHRASES/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString(prettyPrint: false)!).map { print($0) }
    }
    
    static func create(item: MUnitPhrase) -> Observable<Int> {
        // SQL: INSERT INTO UNITPHRASES (TEXTBOOKID, UNIT, PART, SEQNUM, PHRASEID) VALUES (?,?,?,?,?)
        let url = "\(RestApi.url)UNITPHRASES"
        return RestApi.create(url: url, body: try! item.toJSONString(prettyPrint: false)!).map {
            return $0.toInt()!
        }
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        // SQL: DELETE UNITPHRASES WHERE ID=?
        let url = "\(RestApi.url)UNITPHRASES/\(id)"
        return RestApi.delete(url: url).map { print($0) }
    }
}
