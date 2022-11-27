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
class MUnitWords: HasRecords {
    typealias RecordType = MUnitWord
    dynamic var records = [MUnitWord]()
}

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

    static func getDataByTextbook(_ textbook: MTextbook, unitPartFrom: Int, unitPartTo: Int) async -> [MUnitWord] {
        // SQL: SELECT * FROM VUNITWORDS WHERE TEXTBOOKID=? AND UNITPART BETWEEN ? AND ? ORDER BY UNITPART,SEQNUM
        let url = "\(CommonApi.urlAPI)VUNITWORDS?filter=TEXTBOOKID,eq,\(textbook.ID)&filter=UNITPART,bt,\(unitPartFrom),\(unitPartTo)&order=UNITPART&order=SEQNUM"
        let o = await RestApi.getRecords(MUnitWords.self, url: url)
        o.forEach { $0.textbook = textbook }
        return o
    }
    
    static func getDataByTextbook(_ textbook: MTextbook) async -> [MUnitWord] {
        // SQL: SELECT * FROM VUNITWORDS WHERE TEXTBOOKID=? ORDER BY WORDID
        let url = "\(CommonApi.urlAPI)VUNITWORDS?filter=TEXTBOOKID,eq,\(textbook.ID)&order=WORDID"
        let o = await RestApi.getRecords(MUnitWords.self, url: url)
        let arr = Dictionary(grouping: o, by: \.WORDID).values.compactMap { $0[0] }
        arr.forEach { $0.textbook = textbook }
        return arr
    }
    
    private static func setTextbook(_ o: [MUnitWord], arrTextbooks: [MTextbook]) -> [MUnitWord] {
        o.forEach { row in
            row.textbook = arrTextbooks.first { $0.ID == row.TEXTBOOKID }!
        }
        return o
    }

    static func getDataByLang(_ langid: Int, arrTextbooks: [MTextbook]) async -> [MUnitWord] {
        // SQL: SELECT * FROM VTEXTBOOKWORDS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)VUNITWORDS?filter=LANGID,eq,\(langid)&order=TEXTBOOKID&order=UNIT&order=PART&order=SEQNUM"
        return setTextbook(await RestApi.getRecords(MUnitWords.self, url: url), arrTextbooks: arrTextbooks)
    }
    
    static func getDataById(_ id: Int, arrTextbooks: [MTextbook]) async -> MUnitWord? {
        // SQL: SELECT * FROM VUNITWORDS WHERE ID=?
        let url = "\(CommonApi.urlAPI)VUNITWORDS?filter=ID,eq,\(id)"
        let arr = setTextbook(await RestApi.getRecords(MUnitWords.self, url: url), arrTextbooks: arrTextbooks)
        return arr.isEmpty ? nil : arr[0]
    }

    static func getDataByLangWord(langid: Int, word: String, arrTextbooks: [MTextbook]) async -> [MUnitWord] {
        // SQL: SELECT * FROM VUNITWORDS WHERE LANGID=? AND WORD=?
        let url = "\(CommonApi.urlAPI)VUNITWORDS?filter=LANGID,eq,\(langid)&filter=WORD,eq,\(word.urlEncoded())"
        // Api is case insensitive
        return setTextbook((await RestApi.getRecords(url: url)).filter { $0.WORD == word }, arrTextbooks: arrTextbooks)
    }

    static func update(_ id: Int, seqnum: Int) async {
        // SQL: UPDATE UNITWORDS SET SEQNUM=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)UNITWORDS/\(id)"
        let body = "SEQNUM=\(seqnum)"
        print(await RestApi.update(url: url, body: body))
    }

    static func update(item: MUnitWord) async -> String {
        // SQL: CALL UNITWORDS_UPDATE
        let url = "\(CommonApi.urlSP)UNITWORDS_UPDATE"
        let parameters = item.toParameters()
        let o = await RestApi.callSP(url: url, parameters: parameters)
        print(o)
        return o.result
    }

    static func create(item: MUnitWord) async -> Int {
        // SQL: CALL UNITWORDS_CREATE
        let url = "\(CommonApi.urlSP)UNITWORDS_CREATE"
        let parameters = item.toParameters()
        let o = await RestApi.callSP(url: url, parameters: parameters)
        print(o)
        return Int(o.NEW_ID!)!
    }
    
    static func delete(item: MUnitWord) async -> Single<()> {
        // SQL: CALL UNITWORDS_DELETE
        let url = "\(CommonApi.urlSP)UNITWORDS_DELETE"
        let parameters = item.toParameters()
        print(await RestApi.callSP(url: url, parameters: parameters))
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
