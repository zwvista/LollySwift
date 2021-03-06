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

    static func getDataByTextbook(_ textbook: MTextbook, unitPartFrom: Int, unitPartTo: Int) -> Observable<[MUnitWord]> {
        // SQL: SELECT * FROM VUNITWORDS WHERE TEXTBOOKID=? AND UNITPART BETWEEN ? AND ? ORDER BY UNITPART,SEQNUM
        let url = "\(CommonApi.urlAPI)VUNITWORDS?filter=TEXTBOOKID,eq,\(textbook.ID)&filter=UNITPART,bt,\(unitPartFrom),\(unitPartTo)&order=UNITPART&order=SEQNUM"
        let o: Observable<[MUnitWord]> = RestApi.getRecords(url: url)
        return o.do(onNext: { arr in
            arr.forEach { $0.textbook = textbook }
        })
    }
    
    static func getDataByTextbook(_ textbook: MTextbook) -> Observable<[MUnitWord]> {
        // SQL: SELECT * FROM VUNITWORDS WHERE TEXTBOOKID=? ORDER BY WORDID
        let url = "\(CommonApi.urlAPI)VUNITWORDS?filter=TEXTBOOKID,eq,\(textbook.ID)&order=WORDID"
        let o: Observable<[MUnitWord]> = RestApi.getRecords(url: url)
        return o.map { arr in
            Dictionary(grouping: arr, by: \.WORDID).values.compactMap { $0[0] }
        }.do(onNext: { arr in
            arr.forEach { $0.textbook = textbook }
        })
    }
    
    private static func setTextbook(_ o: Observable<[MUnitWord]>, arrTextbooks: [MTextbook]) -> Observable<[MUnitWord]> {
        return o.do(onNext: { arr in
            arr.forEach { row in
                row.textbook = arrTextbooks.first { $0.ID == row.TEXTBOOKID }!
            }
        })
    }

    static func getDataByLang(_ langid: Int, arrTextbooks: [MTextbook]) -> Observable<[MUnitWord]> {
        // SQL: SELECT * FROM VTEXTBOOKWORDS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)VUNITWORDS?filter=LANGID,eq,\(langid)&order=TEXTBOOKID&order=UNIT&order=PART&order=SEQNUM"
        return setTextbook(RestApi.getRecords(url: url), arrTextbooks: arrTextbooks)
    }
    
    static func getDataById(_ id: Int, arrTextbooks: [MTextbook]) -> Observable<MUnitWord?> {
        // SQL: SELECT * FROM VUNITWORDS WHERE ID=?
        let url = "\(CommonApi.urlAPI)VUNITWORDS?filter=ID,eq,\(id)"
        return setTextbook(RestApi.getRecords(url: url), arrTextbooks: arrTextbooks).map { $0.isEmpty ? nil : $0[0] }
    }

    static func getDataByLangWord(langid: Int, word: String, arrTextbooks: [MTextbook]) -> Observable<[MUnitWord]> {
        // SQL: SELECT * FROM VUNITWORDS WHERE LANGID=? AND WORD=?
        let url = "\(CommonApi.urlAPI)VUNITWORDS?filter=LANGID,eq,\(langid)&filter=WORD,eq,\(word.urlEncoded())"
        // Api is case insensitive
        return setTextbook(RestApi.getRecords(url: url).map { $0.filter { $0.WORD == word } }, arrTextbooks: arrTextbooks)
    }

    static func update(_ id: Int, seqnum: Int) -> Observable<()> {
        // SQL: UPDATE UNITWORDS SET SEQNUM=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)UNITWORDS/\(id)"
        let body = "SEQNUM=\(seqnum)"
        return RestApi.update(url: url, body: body).map { print($0) }
    }

    static func update(item: MUnitWord) -> Observable<String> {
        // SQL: CALL UNITWORDS_UPDATE
        let url = "\(CommonApi.urlSP)UNITWORDS_UPDATE"
        let parameters = item.toParameters()
        return RestApi.callSP(url: url, parameters: parameters).map { print($0); return $0.result }
    }

    static func create(item: MUnitWord) -> Observable<Int> {
        // SQL: CALL UNITWORDS_CREATE
        let url = "\(CommonApi.urlSP)UNITWORDS_CREATE"
        let parameters = item.toParameters()
        return RestApi.callSP(url: url, parameters: parameters).map { print($0); return Int($0.NEW_ID!)! }
    }
    
    static func delete(item: MUnitWord) -> Observable<()> {
        // SQL: CALL UNITWORDS_DELETE
        let url = "\(CommonApi.urlSP)UNITWORDS_DELETE"
        let parameters = item.toParameters()
        return RestApi.callSP(url: url, parameters: parameters).map { print($0) }
    }
}

class MUnitWordEdit {
    let ID: BehaviorRelay<String>
    let TEXTBOOKNAME: BehaviorRelay<String>
    let UNITSTR: BehaviorRelay<String>
    let indexUNIT: BehaviorRelay<Int>
    let PARTSTR: BehaviorRelay<String>
    let indexPART: BehaviorRelay<Int>
    let SEQNUM: BehaviorRelay<String>
    let WORDID: BehaviorRelay<String>
    let WORD: BehaviorRelay<String>
    let NOTE: BehaviorRelay<String>
    let FAMIID: BehaviorRelay<String>
    let ACCURACY: BehaviorRelay<String>
    let WORDS = BehaviorRelay(value: "")

    init(x: MUnitWord) {
        ID = BehaviorRelay(value: String(x.ID))
        TEXTBOOKNAME = BehaviorRelay(value: x.TEXTBOOKNAME)
        UNITSTR = BehaviorRelay(value: x.UNITSTR)
        indexUNIT = BehaviorRelay(value: x.textbook.arrUnits.firstIndex { $0.value == x.UNIT } ?? -1)
        PARTSTR = BehaviorRelay(value: x.PARTSTR)
        indexPART = BehaviorRelay(value: x.textbook.arrParts.firstIndex { $0.value == x.PART } ?? -1)
        SEQNUM = BehaviorRelay(value: String(x.SEQNUM))
        WORDID = BehaviorRelay(value: String(x.WORDID))
        WORD = BehaviorRelay(value: x.WORD)
        NOTE = BehaviorRelay(value: x.NOTE)
        FAMIID = BehaviorRelay(value: String(x.FAMIID))
        ACCURACY = BehaviorRelay(value: x.ACCURACY)
    }
    
    func save(to x: MUnitWord) {
        if indexUNIT.value != -1 {
            x.UNIT = x.textbook.arrUnits[indexUNIT.value].value
        }
        if indexPART.value != -1 {
            x.PART = x.textbook.arrUnits[indexPART.value].value
        }
        x.SEQNUM = Int(SEQNUM.value)!
        x.WORD = WORD.value
        x.NOTE = NOTE.value
    }
}
