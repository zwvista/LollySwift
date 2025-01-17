//
//  MUnitWord.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/06/25.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

@objcMembers
class MUnitWords: HasRecords, @unchecked Sendable {
    typealias RecordType = MUnitWord
    dynamic var records = [MUnitWord]()
}

@objcMembers
class MUnitWord: NSObject, Codable, MWordProtocol, @unchecked Sendable {
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
        let records = await RestApi.getRecords(MUnitWords.self, url: url)
        return setTextbook(records.filter { $0.WORD == word }, arrTextbooks: arrTextbooks)
    }

    static func update(_ id: Int, seqnum: Int) async {
        // SQL: UPDATE UNITWORDS SET SEQNUM=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)UNITWORDS/\(id)"
        let body = ["SEQNUM": seqnum]
        print(await RestApi.update(url: url, body: body))
    }

    static func update(item: MUnitWord) async -> String {
        // SQL: CALL UNITWORDS_UPDATE
        let url = "\(CommonApi.urlSP)UNITWORDS_UPDATE"
        let parameters = item.toParameters(isSP: true)
        let o = await RestApi.callSP(url: url, parameters: parameters)
        print(o)
        return o.result
    }

    static func create(item: MUnitWord) async -> Int {
        // SQL: CALL UNITWORDS_CREATE
        let url = "\(CommonApi.urlSP)UNITWORDS_CREATE"
        let parameters = item.toParameters(isSP: true)
        let o = await RestApi.callSP(url: url, parameters: parameters)
        print(o)
        return Int(o.NEW_ID!)!
    }

    static func delete(item: MUnitWord) async {
        // SQL: CALL UNITWORDS_DELETE
        let url = "\(CommonApi.urlSP)UNITWORDS_DELETE"
        let parameters = item.toParameters(isSP: true)
        print(await RestApi.callSP(url: url, parameters: parameters))
    }
}

class MUnitWordEdit: ObservableObject {
    let ID: String
    let TEXTBOOKNAME: String
    @Published var UNITSTR: String
    @Published var indexUNIT: Int
    @Published var PARTSTR: String
    @Published var indexPART: Int
    @Published var SEQNUM: String
    let WORDID: String
    @Published var WORD: String
    @Published var NOTE: String
    let FAMIID: String
    var CORRECT: Int
    var TOTAL: Int
    @Published var ACCURACY: String
    @Published var WORDS = ""

    init(x: MUnitWord) {
        ID = "\(x.ID)"
        TEXTBOOKNAME = x.TEXTBOOKNAME
        UNITSTR = x.UNITSTR
        indexUNIT = x.textbook.arrUnits.firstIndex { $0.value == x.UNIT } ?? -1
        PARTSTR = x.PARTSTR
        indexPART = x.textbook.arrParts.firstIndex { $0.value == x.PART } ?? -1
        SEQNUM = String(x.SEQNUM)
        WORDID = "\(x.WORDID)"
        WORD = x.WORD
        NOTE = x.NOTE
        FAMIID = "\(x.FAMIID)"
        CORRECT = x.CORRECT
        TOTAL = x.TOTAL
        ACCURACY = x.ACCURACY
    }

    func clearAccuracy() {
        CORRECT = 0
        TOTAL = 0
        ACCURACY = CommonApi.getAccuracy(CORRECT: CORRECT, TOTAL: TOTAL)
    }

    func save(to x: MUnitWord) {
        if indexUNIT != -1 {
            x.UNIT = x.textbook.arrUnits[indexUNIT].value
        }
        if indexPART != -1 {
            x.PART = x.textbook.arrUnits[indexPART].value
        }
        x.SEQNUM = Int(SEQNUM)!
        x.WORD = WORD
        x.NOTE = NOTE
        x.CORRECT = CORRECT
        x.TOTAL = TOTAL
    }
}
