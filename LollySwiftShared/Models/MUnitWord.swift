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
    dynamic var ID = 0
    dynamic var LANGID = 0
    dynamic var TEXTBOOKID = 0
    dynamic var TEXTBOOKNAME = ""
    dynamic var UNIT = 0
    dynamic var PART = 0
    dynamic var SEQNUM = 0
    dynamic var WORDID = 0
    dynamic var WORD = ""
    dynamic var NOTE: String?
    dynamic var FAMIID = 0
    dynamic var LEVEL = 0
    dynamic var CORRECT = 0
    dynamic var TOTAL = 0

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
    var UNITSTR: String { textbook.UNITSTR(UNIT) }
    var PARTSTR: String { textbook.PARTSTR(PART) }
    var UNITPARTSEQNUM: String { "\(UNITSTR)\n\(PARTSTR)\n\(SEQNUM)" }
    var WORDNOTE: String { WORD + ((NOTE ?? "").isEmpty ? "" : "(\(NOTE!))") }
    var ACCURACY: String { CommonApi.getAccuracy(CORRECT: CORRECT, TOTAL: TOTAL) }
    
    func copy(from x: MUnitWord) {
        ID = x.ID
        LANGID = x.LANGID
        TEXTBOOKID = x.TEXTBOOKID
        TEXTBOOKNAME = x.TEXTBOOKNAME
        UNIT = x.UNIT
        PART = x.PART
        SEQNUM = x.SEQNUM
        WORDID = x.WORDID
        WORD = x.WORD
        NOTE = x.NOTE
        FAMIID = x.FAMIID
        LEVEL = x.LEVEL
        CORRECT = x.CORRECT
        TOTAL = x.TOTAL
        textbook = x.textbook
    }

    public override var description: String { "\(SEQNUM) \(WORD)" + (NOTE?.isEmpty != false ? "" : "(\(NOTE!))") }

    static func getDataByTextbook(_ textbook: MTextbook, unitPartFrom: Int, unitPartTo: Int) -> Observable<[MUnitWord]> {
        // SQL: SELECT * FROM VUNITWORDS WHERE TEXTBOOKID=? AND UNITPART BETWEEN ? AND ? ORDER BY UNITPART,SEQNUM
        let url = "\(CommonApi.url)VUNITWORDS?filter=TEXTBOOKID,eq,\(textbook.ID)&filter=UNITPART,bt,\(unitPartFrom),\(unitPartTo)&order=UNITPART&order=SEQNUM"
        let o: Observable<[MUnitWord]> = RestApi.getRecords(url: url)
        return o.do(onNext: { arr in
            arr.forEach { $0.textbook = textbook }
        })
    }

    static func getDataByLang(_ langid: Int, arrTextbooks: [MTextbook]) -> Observable<[MUnitWord]> {
        // SQL: SELECT * FROM VTEXTBOOKWORDS WHERE LANGID=?
        let url = "\(CommonApi.url)VUNITWORDS?filter=LANGID,eq,\(langid)&order=TEXTBOOKID&order=UNIT&order=PART&order=SEQNUM"
        let o: Observable<[MUnitWord]> = RestApi.getRecords(url: url)
        return o.do(onNext: { arr in
            arr.forEach { row in
                row.textbook = arrTextbooks.first { $0.ID == row.TEXTBOOKID }!
            }
        })
    }

    static func getDataByWordId(_ wordid: Int) -> Observable<[MUnitWord]> {
        // SQL: SELECT * FROM VUNITWORDS WHERE WORDID=?
        let url = "\(CommonApi.url)VUNITWORDS?filter=WORDID,eq,\(wordid)"
        return RestApi.getRecords(url: url)
    }

    static func getDataByLangWord(langid: Int, word: String, arrTextbooks: [MTextbook]) -> Observable<[MUnitWord]> {
        // SQL: SELECT * FROM VUNITWORDS WHERE LANGID=? AND WORD=?
        let url = "\(CommonApi.url)VUNITWORDS?filter=LANGID,eq,\(langid)&filter=WORD,eq,\(word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
        // Api is case insensitive
        let o: Observable<[MUnitWord]> = RestApi.getRecords(url: url).map { $0.filter { $0.WORD == word } }
        return o.do(onNext: { arr in
            arr.forEach { row in
                row.textbook = arrTextbooks.first { $0.ID == row.TEXTBOOKID }!
            }
        })
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
        return RestApi.create(url: url, body: try! item.toJSONString(prettyPrint: false)!).map { $0.toInt()! }.do(onNext: { print($0) })
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        // SQL: DELETE UNITWORDS WHERE ID=?
        let url = "\(CommonApi.url)UNITWORDS/\(id)"
        return RestApi.delete(url: url).map { print($0) }
    }
}
