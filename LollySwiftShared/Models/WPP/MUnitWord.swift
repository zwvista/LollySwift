//
//  MUnitWord.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/06/25.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

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
    dynamic var NOTE = ""
    dynamic var FAMIID = 0
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
        case CORRECT
        case TOTAL
    }

    unowned var textbook: MTextbook!
    var UNITSTR: String { textbook.UNITSTR(UNIT) }
    var PARTSTR: String { textbook.PARTSTR(PART) }
    var UNITPARTSEQNUM: String { "\(UNITSTR)\n\(PARTSTR)\n\(SEQNUM)" }
    var WORDNOTE: String { WORD + (NOTE.isEmpty ? "" : "(\(NOTE))") }
    var ACCURACY: String { CommonApi.getAccuracy(CORRECT: CORRECT, TOTAL: TOTAL) }

    public override var description: String { "\(SEQNUM) \(WORD)" + (NOTE.isEmpty ? "" : "(\(NOTE))") }

    static func getDataByTextbook(_ textbook: MTextbook, unitPartFrom: Int, unitPartTo: Int) -> Single<[MUnitWord]> {
        // SQL: SELECT * FROM VUNITWORDS WHERE TEXTBOOKID=? AND UNITPART BETWEEN ? AND ? ORDER BY UNITPART,SEQNUM
        let url = "\(CommonApi.urlAPI)VUNITWORDS?filter=TEXTBOOKID,eq,\(textbook.ID)&filter=UNITPART,bt,\(unitPartFrom),\(unitPartTo)&order=UNITPART&order=SEQNUM"
        let o: Single<[MUnitWord]> = RestApi.getRecords(url: url)
        return o.do(onSuccess: { arr in
            arr.forEach { $0.textbook = textbook }
        })
    }

    static func getDataByTextbook(_ textbook: MTextbook) -> Single<[MUnitWord]> {
        // SQL: SELECT * FROM VUNITWORDS WHERE TEXTBOOKID=? ORDER BY WORDID
        let url = "\(CommonApi.urlAPI)VUNITWORDS?filter=TEXTBOOKID,eq,\(textbook.ID)&order=WORDID"
        let o: Single<[MUnitWord]> = RestApi.getRecords(url: url)
        return o.map { arr in
            Dictionary(grouping: arr, by: \.WORDID).values.compactMap { $0[0] }
        }.do(onSuccess: { arr in
            arr.forEach { $0.textbook = textbook }
        })
    }

    private static func setTextbook(_ o: Single<[MUnitWord]>, arrTextbooks: [MTextbook]) -> Single<[MUnitWord]> {
        return o.do(onSuccess: { arr in
            arr.forEach { row in
                row.textbook = arrTextbooks.first { $0.ID == row.TEXTBOOKID }!
            }
        })
    }

    static func getDataByLang(_ langid: Int, arrTextbooks: [MTextbook]) -> Single<[MUnitWord]> {
        // SQL: SELECT * FROM VTEXTBOOKWORDS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)VUNITWORDS?filter=LANGID,eq,\(langid)&order=TEXTBOOKID&order=UNIT&order=PART&order=SEQNUM"
        return setTextbook(RestApi.getRecords(url: url), arrTextbooks: arrTextbooks)
    }

    static func getDataById(_ id: Int, arrTextbooks: [MTextbook]) -> Single<MUnitWord?> {
        // SQL: SELECT * FROM VUNITWORDS WHERE ID=?
        let url = "\(CommonApi.urlAPI)VUNITWORDS?filter=ID,eq,\(id)"
        return setTextbook(RestApi.getRecords(url: url), arrTextbooks: arrTextbooks).map { $0.isEmpty ? nil : $0[0] }
    }

    static func getDataByLangWord(langid: Int, word: String, arrTextbooks: [MTextbook]) -> Single<[MUnitWord]> {
        // SQL: SELECT * FROM VUNITWORDS WHERE LANGID=? AND WORD=?
        let url = "\(CommonApi.urlAPI)VUNITWORDS?filter=LANGID,eq,\(langid)&filter=WORD,eq,\(word.urlEncoded())"
        // Api is case insensitive
        return setTextbook(RestApi.getRecords(url: url).map { $0.filter { $0.WORD == word } }, arrTextbooks: arrTextbooks)
    }

    static func update(_ id: Int, seqnum: Int) -> Single<()> {
        // SQL: UPDATE UNITWORDS SET SEQNUM=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)UNITWORDS/\(id)"
        let body = "SEQNUM=\(seqnum)"
        return RestApi.update(url: url, body: body).map { print($0) }
    }

    static func update(item: MUnitWord) -> Single<String> {
        // SQL: CALL UNITWORDS_UPDATE
        let url = "\(CommonApi.urlSP)UNITWORDS_UPDATE"
        let parameters = item.toParameters()
        return RestApi.callSP(url: url, parameters: parameters).map { print($0); return $0.result }
    }

    static func create(item: MUnitWord) -> Single<Int> {
        // SQL: CALL UNITWORDS_CREATE
        let url = "\(CommonApi.urlSP)UNITWORDS_CREATE"
        let parameters = item.toParameters()
        return RestApi.callSP(url: url, parameters: parameters).map { print($0); return Int($0.NEW_ID!)! }
    }

    static func delete(item: MUnitWord) -> Single<()> {
        // SQL: CALL UNITWORDS_DELETE
        let url = "\(CommonApi.urlSP)UNITWORDS_DELETE"
        let parameters = item.toParameters()
        return RestApi.callSP(url: url, parameters: parameters).map { print($0) }
    }
}

class MUnitWordEdit {
    let ID: String
    let TEXTBOOKNAME: String
    let UNITSTR_: BehaviorRelay<String>
    var UNITSTR: String { get { UNITSTR_.value } set { UNITSTR_.accept(newValue) } }
    let indexUNIT_: BehaviorRelay<Int>
    var indexUNIT: Int { get { indexUNIT_.value } set { indexUNIT_.accept(newValue) } }
    let PARTSTR_: BehaviorRelay<String>
    var PARTSTR: String { get { PARTSTR_.value } set { PARTSTR_.accept(newValue) } }
    let indexPART_: BehaviorRelay<Int>
    var indexPART: Int { get { indexPART_.value } set { indexPART_.accept(newValue) } }
    let SEQNUM: BehaviorRelay<String>
    let WORDID: String
    let WORD: BehaviorRelay<String>
    let NOTE: BehaviorRelay<String>
    let FAMIID: String
    let ACCURACY: BehaviorRelay<String>
    let WORDS = BehaviorRelay(value: "")

    init(x: MUnitWord) {
        ID = "\(x.ID)"
        TEXTBOOKNAME = x.TEXTBOOKNAME
        UNITSTR_ = BehaviorRelay(value: x.UNITSTR)
        indexUNIT_ = BehaviorRelay(value: x.textbook.arrUnits.firstIndex { $0.value == x.UNIT } ?? -1)
        PARTSTR_ = BehaviorRelay(value: x.PARTSTR)
        indexPART_ = BehaviorRelay(value: x.textbook.arrParts.firstIndex { $0.value == x.PART } ?? -1)
        SEQNUM = BehaviorRelay(value: String(x.SEQNUM))
        WORDID = "\(x.WORDID)"
        WORD = BehaviorRelay(value: x.WORD)
        NOTE = BehaviorRelay(value: x.NOTE)
        FAMIID = "\(x.FAMIID)"
        ACCURACY = BehaviorRelay(value: x.ACCURACY)
    }

    func save(to x: MUnitWord) {
        if indexUNIT != -1 {
            x.UNIT = x.textbook.arrUnits[indexUNIT].value
        }
        if indexPART != -1 {
            x.PART = x.textbook.arrUnits[indexPART].value
        }
        x.SEQNUM = Int(SEQNUM.value)!
        x.WORD = WORD.value
        x.NOTE = NOTE.value
    }
}
