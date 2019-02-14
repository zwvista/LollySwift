//
//  MUnitWord.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/06/25.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
class MUnitWord: NSObject, Codable {
    var ID = 0
    var LANGID = 0
    var TEXTBOOKID = 0
    var UNIT = 0
    var PART = 0
    var SEQNUM = 0
    var WORD = ""
    var NOTE: String?
    var LEVEL = 0
    var LANGWORDID = 0
    
    func PARTSTR(arrParts: [String]) -> String {
        return arrParts[PART - 1]
    }
    func UNITPARTSEQNUM(arrParts: [String]) -> String {
        return "\(UNIT) \(SEQNUM)\n\(PARTSTR(arrParts: arrParts))"
    }
    var WORDNOTE: String {
        return WORD + ((NOTE ?? "").isEmpty ? "" : "(\(NOTE!))")
    }

    static func getDataByTextbook(_ textbookid: Int, unitPartFrom: Int, unitPartTo: Int) -> Observable<[MUnitWord]> {
        // SQL: SELECT * FROM VUNITWORDS WHERE TEXTBOOKID=? AND UNITPART BETWEEN ? AND ? ORDER BY UNITPART,SEQNUM
        let url = "\(RestApi.url)VUNITWORDS?transform=1&filter[]=TEXTBOOKID,eq,\(textbookid)&filter[]=UNITPART,bt,\(unitPartFrom),\(unitPartTo)&order[]=UNITPART&order[]=SEQNUM"
        return RestApi.getArray(url: url, keyPath: "VUNITWORDS")
    }
    
    static func getDataByLangWord(_ langwordid: Int) -> Observable<[MUnitWord]> {
        // SQL: SELECT * FROM VUNITWORDS WHERE LANGWORDID=?
        let url = "\(RestApi.url)VUNITWORDS?transform=1&filter=LANGWORDID,eq,\(langwordid)"
        return RestApi.getArray(url: url, keyPath: "VUNITWORDS")
    }

    static func update(_ id: Int, seqnum: Int) -> Observable<String> {
        // SQL: UPDATE UNITWORDS SET SEQNUM=? WHERE ID=?
        let url = "\(RestApi.url)UNITWORDS/\(id)"
        let body = "SEQNUM=\(seqnum)"
        return RestApi.update(url: url, body: body)
    }

    static func update(item: MUnitWord) -> Observable<String> {
        // SQL: UPDATE UNITWORDS SET UNIT=?, PART=?, SEQNUM=?, LANGWORDID=? WHERE ID=?
        let url = "\(RestApi.url)UNITWORDS/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString(prettyPrint: false)!)
    }
    
    static func create(item: MUnitWord) -> Observable<Int> {
        // SQL: INSERT INTO UNITWORDS (TEXTBOOKID, UNIT, PART, SEQNUM, LANGWORDID) VALUES (?,?,?,?,?)
        let url = "\(RestApi.url)UNITWORDS"
        return RestApi.create(url: url, body: try! item.toJSONString(prettyPrint: false)!).map {
            return $0.toInt()!
        }
    }
    
    static func delete(_ id: Int) -> Observable<String> {
        // SQL: DELETE UNITWORDS WHERE ID=?
        let url = "\(RestApi.url)UNITWORDS/\(id)"
        return RestApi.delete(url: url)
    }
}
