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
class MUnitWord: NSObject, Codable, MWordProtocol {
    var ID = 0
    var LANGID = 0
    var TEXTBOOKID = 0
    var TEXTBOOKNAME = ""
    var UNIT = 0
    var PART = 0
    var SEQNUM = 0
    var WORDID = 0
    var WORD = ""
    var NOTE: String?
    var FAMIID = 0
    var LEVEL = 0
    var CORRECT = 0
    var TOTAL = 0

    enum CodingKeys : String, CodingKey {
        case ID
        case LANGID
        case TEXTBOOKID
        case TEXTBOOKNAME
        case UNIT
        case PART
        case SEQNUM
        case WORDID
        case WORD
        case NOTE
        case FAMIID
        case LEVEL
        case CORRECT
        case TOTAL
    }

    unowned var textbook: MTextbook!
    var UNITSTR: String {
        return textbook.UNITSTR(UNIT)
    }
    var PARTSTR: String {
        return textbook.PARTSTR(PART)
    }
    var UNITPARTSEQNUM: String {
        return "\(UNITSTR) \(SEQNUM)\n\(PARTSTR)"
    }
    var WORDNOTE: String {
        return WORD + ((NOTE ?? "").isEmpty ? "" : "(\(NOTE!))")
    }
    var ACCURACY: String {
        return TOTAL == 0 ? "N/A" : (floor(CORRECT.toDouble / TOTAL.toDouble * 10) / 10).toString
    }

    public override var description: String {
        return "\(SEQNUM) \(WORD)" + (NOTE?.isEmpty != false ? "" : "(\(NOTE!))")
    }

    static func getDataByTextbook(_ textbook: MTextbook, unitPartFrom: Int, unitPartTo: Int) -> Observable<[MUnitWord]> {
        // SQL: SELECT * FROM VUNITWORDS WHERE TEXTBOOKID=? AND UNITPART BETWEEN ? AND ? ORDER BY UNITPART,SEQNUM
        let url = "\(CommonApi.url)VUNITWORDS?transform=1&filter[]=TEXTBOOKID,eq,\(textbook.ID)&filter[]=UNITPART,bt,\(unitPartFrom),\(unitPartTo)&order[]=UNITPART&order[]=SEQNUM"
        let o: Observable<[MUnitWord]> = RestApi.getArray(url: url, keyPath: "VUNITWORDS")
        return o.map { arr in
            arr.forEach { $0.textbook = textbook }
            return arr
        }
    }

    static func getDataByLang(_ langid: Int, arrTextbooks: [MTextbook]) -> Observable<[MUnitWord]> {
        // SQL: SELECT * FROM VTEXTBOOKWORDS WHERE LANGID=?
        let url = "\(CommonApi.url)VUNITWORDS?transform=1&filter=LANGID,eq,\(langid)&order[]=TEXTBOOKID&order[]=UNIT&order[]=PART&order[]=SEQNUM"
        let o: Observable<[MUnitWord]> = RestApi.getArray(url: url, keyPath: "VUNITWORDS")
        return o.map { arr in
            arr.forEach { row in
                row.textbook = arrTextbooks.first { $0.ID == row.TEXTBOOKID }!
            }
            return arr
        }
    }

    static func getDataByLangWord(_ wordid: Int) -> Observable<[MUnitWord]> {
        // SQL: SELECT * FROM VUNITWORDS WHERE WORDID=?
        let url = "\(CommonApi.url)VUNITWORDS?transform=1&filter=WORDID,eq,\(wordid)"
        return RestApi.getArray(url: url, keyPath: "VUNITWORDS")
    }

    static func update(_ id: Int, seqnum: Int) -> Observable<()> {
        // SQL: UPDATE UNITWORDS SET SEQNUM=? WHERE ID=?
        let url = "\(CommonApi.url)UNITWORDS/\(id)"
        let body = "SEQNUM=\(seqnum)"
        return RestApi.update(url: url, body: body).map { print($0) }
    }

    static func update(item: MUnitWord) -> Observable<()> {
        // SQL: UPDATE UNITWORDS SET UNIT=?, PART=?, SEQNUM=?, WORDID=? WHERE ID=?
        let url = "\(CommonApi.url)UNITWORDS/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString(prettyPrint: false)!).map { print($0) }
    }

    static func create(item: MUnitWord) -> Observable<Int> {
        // SQL: INSERT INTO UNITWORDS (TEXTBOOKID, UNIT, PART, SEQNUM, WORDID) VALUES (?,?,?,?,?)
        let url = "\(CommonApi.url)UNITWORDS"
        return RestApi.create(url: url, body: try! item.toJSONString(prettyPrint: false)!).map {
            return $0.toInt()!
        }
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        // SQL: DELETE UNITWORDS WHERE ID=?
        let url = "\(CommonApi.url)UNITWORDS/\(id)"
        return RestApi.delete(url: url).map { print($0) }
    }
}
