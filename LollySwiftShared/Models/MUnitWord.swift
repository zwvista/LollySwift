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
    var WORDID = 0
    var WORD = ""
    var NOTE: String?
    var FAMIID = 0
    var LEVEL = 0

    enum CodingKeys : String, CodingKey {
        case ID
        case LANGID
        case TEXTBOOKID
        case UNIT
        case PART
        case SEQNUM
        case WORDID
        case WORD
        case NOTE
        case FAMIID
        case LEVEL
    }

    var arrUnits: NSArray!
    var arrParts: NSArray!
    var UNITSTR: String {
        return (arrUnits as! [MSelectItem]).first { $0.value == UNIT }!.label
    }
    var PARTSTR: String {
        return (arrParts as! [MSelectItem]).first { $0.value == PART }!.label
    }
    var UNITPARTSEQNUM: String {
        return "\(UNITSTR) \(SEQNUM)\n\(PARTSTR)"
    }

    static func getDataByTextbook(_ textbookid: Int, unitPartFrom: Int, unitPartTo: Int, arrUnits: [MSelectItem], arrParts: [MSelectItem]) -> Observable<[MUnitWord]> {
        // SQL: SELECT * FROM VUNITWORDS WHERE TEXTBOOKID=? AND UNITPART BETWEEN ? AND ? ORDER BY UNITPART,SEQNUM
        let url = "\(RestApi.url)VUNITWORDS?transform=1&filter[]=TEXTBOOKID,eq,\(textbookid)&filter[]=UNITPART,bt,\(unitPartFrom),\(unitPartTo)&order[]=UNITPART&order[]=SEQNUM"
        let o: Observable<[MUnitWord]> = RestApi.getArray(url: url, keyPath: "VUNITWORDS")
        return o.map { arr in
            arr.forEach { row in
                row.arrUnits = arrUnits as NSArray
                row.arrParts = arrParts as NSArray
            }
            return arr
        }
    }
    
    static func getDataByLangWord(_ wordid: Int) -> Observable<[MUnitWord]> {
        // SQL: SELECT * FROM VUNITWORDS WHERE WORDID=?
        let url = "\(RestApi.url)VUNITWORDS?transform=1&filter=WORDID,eq,\(wordid)"
        return RestApi.getArray(url: url, keyPath: "VUNITWORDS")
    }

    static func update(_ id: Int, seqnum: Int) -> Observable<()> {
        // SQL: UPDATE UNITWORDS SET SEQNUM=? WHERE ID=?
        let url = "\(RestApi.url)UNITWORDS/\(id)"
        let body = "SEQNUM=\(seqnum)"
        return RestApi.update(url: url, body: body).map { print($0) }
    }

    static func update(item: MUnitWord) -> Observable<()> {
        // SQL: UPDATE UNITWORDS SET UNIT=?, PART=?, SEQNUM=?, WORDID=? WHERE ID=?
        let url = "\(RestApi.url)UNITWORDS/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString(prettyPrint: false)!).map { print($0) }
    }
    
    static func create(item: MUnitWord) -> Observable<Int> {
        // SQL: INSERT INTO UNITWORDS (TEXTBOOKID, UNIT, PART, SEQNUM, WORDID) VALUES (?,?,?,?,?)
        let url = "\(RestApi.url)UNITWORDS"
        return RestApi.create(url: url, body: try! item.toJSONString(prettyPrint: false)!).map {
            return $0.toInt()!
        }
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        // SQL: DELETE UNITWORDS WHERE ID=?
        let url = "\(RestApi.url)UNITWORDS/\(id)"
        return RestApi.delete(url: url).map { print($0) }
    }
}
