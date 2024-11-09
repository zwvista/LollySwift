//
//  MUnitPhrase.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/07.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

@objcMembers
class MUnitPhrases: HasRecords, @unchecked Sendable {
    typealias RecordType = MUnitPhrase
    dynamic var records = [MUnitPhrase]()
}

@objcMembers
class MUnitPhrase: NSObject, Codable, MPhraseProtocol, @unchecked Sendable {
    dynamic var ID = 0
    dynamic var LANGID = 0
    dynamic var TEXTBOOKID = 0
    dynamic var TEXTBOOKNAME = ""
    dynamic var UNIT = 0
    dynamic var PART = 0
    dynamic var SEQNUM = 0
    dynamic var PHRASEID = 0
    dynamic var PHRASE = ""
    dynamic var TRANSLATION = ""

    enum CodingKeys : String, CodingKey {
        case ID
        case LANGID
        case TEXTBOOKID
        case TEXTBOOKNAME
        case UNIT
        case PART
        case SEQNUM
        case PHRASEID
        case PHRASE
        case TRANSLATION
    }

    unowned var textbook: MTextbook!
    var UNITSTR: String { textbook.UNITSTR(UNIT) }
    var PARTSTR: String { textbook.PARTSTR(PART) }
    var UNITPARTSEQNUM: String { "\(UNITSTR)\n\(PARTSTR)\n\(SEQNUM)" }

    static func getDataByTextbook(_ textbook: MTextbook, unitPartFrom: Int, unitPartTo: Int) async -> [MUnitPhrase] {
        // SQL: SELECT * FROM VUNITPHRASES WHERE TEXTBOOKID=? AND UNITPART BETWEEN ? AND ? ORDER BY UNITPART,SEQNUM
        let url = "\(CommonApi.urlAPI)VUNITPHRASES?filter=TEXTBOOKID,eq,\(textbook.ID)&filter=UNITPART,bt,\(unitPartFrom),\(unitPartTo)&order=UNITPART&order=SEQNUM"
        let o = await RestApi.getRecords(MUnitPhrases.self, url: url)
        o.forEach { $0.textbook = textbook }
        return o
    }

    static func getDataByTextbook(_ textbook: MTextbook) async -> [MUnitPhrase] {
        // SQL: SELECT * FROM VUNITPHRASES WHERE TEXTBOOKID=? ORDER BY PHRASEID
        let url = "\(CommonApi.urlAPI)VUNITPHRASES?filter=TEXTBOOKID,eq,\(textbook.ID)&order=PHRASEID"
        let o = await RestApi.getRecords(MUnitPhrases.self, url: url)
        o.forEach { $0.textbook = textbook }
        return o
    }

    private static func setTextbook(_ o: [MUnitPhrase], arrTextbooks: [MTextbook]) -> [MUnitPhrase] {
        let arr = Dictionary(grouping: o, by: \.PHRASEID).values.compactMap { $0[0] }
        arr.forEach { row in
            row.textbook = arrTextbooks.first { $0.ID == row.TEXTBOOKID }!
        }
        return arr
    }

    static func getDataByLang(_ langid: Int, arrTextbooks: [MTextbook]) async -> [MUnitPhrase] {
        // SQL: SELECT * FROM VTEXTBOOKPHRASES WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)VUNITPHRASES?filter=LANGID,eq,\(langid)&order=TEXTBOOKID&order=UNIT&order=PART&order=SEQNUM"
        return setTextbook(await RestApi.getRecords(MUnitPhrases.self, url: url), arrTextbooks: arrTextbooks)
    }

    static func getDataById(_ id: Int, arrTextbooks: [MTextbook]) async -> MUnitPhrase? {
        // SQL: SELECT * FROM VUNITPHRASES WHERE ID=?
        let url = "\(CommonApi.urlAPI)VUNITPHRASES?filter=ID,eq,\(id)"
        let arr = setTextbook(await RestApi.getRecords(MUnitPhrases.self, url: url), arrTextbooks: arrTextbooks)
        return arr.isEmpty ? nil : arr[0]
    }

    static func getDataByLangPhrase(langid: Int, phrase: String, arrTextbooks: [MTextbook]) async -> [MUnitPhrase] {
        // SQL: SELECT * FROM VUNITPHRASES WHERE LANGID=? AND PHRASE=?
        let url = "\(CommonApi.urlAPI)VUNITPHRASES?filter=LANGID,eq,\(langid)&filter=PHRASE,eq,\(phrase.urlEncoded())"
        // Api is case insensitive
        return setTextbook((await RestApi.getRecords(MUnitPhrases.self, url: url)).filter { $0.PHRASE == phrase }, arrTextbooks: arrTextbooks)
    }

    static func update(_ id: Int, seqnum: Int) async {
        // SQL: UPDATE UNITPHRASES SET SEQNUM=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)UNITPHRASES/\(id)"
        let body = ["SEQNUM": seqnum]
        print(await RestApi.update(url: url, body: body))
    }

    static func update(item: MUnitPhrase) async {
        // SQL: CALL UNITPHRASES_UPDATE
        let url = "\(CommonApi.urlSP)UNITPHRASES_UPDATE"
        let parameters = item.toParameters(isSP: true)
        print(await RestApi.callSP(url: url, parameters: parameters))
    }

    static func create(item: MUnitPhrase) async -> Int {
        // SQL: CALL UNITPHRASES_CREATE
        let url = "\(CommonApi.urlSP)UNITPHRASES_CREATE"
        let parameters = item.toParameters(isSP: true)
        let o = await RestApi.callSP(url: url, parameters: parameters)
        print(o)
        return Int(o.NEW_ID!)!
    }

    static func delete(item: MUnitPhrase) async {
        // SQL: CALL UNITPHRASES_DELETE
        let url = "\(CommonApi.urlSP)UNITPHRASES_DELETE"
        let parameters = item.toParameters(isSP: true)
        print(await RestApi.callSP(url: url, parameters: parameters))
    }
}

class MUnitPhraseEdit: ObservableObject {
    let ID: String
    let TEXTBOOKNAME: String
    @Published var UNITSTR: String
    @Published var indexUNIT: Int
    @Published var PARTSTR: String
    @Published var indexPART: Int
    @Published var SEQNUM: String
    let PHRASEID: String
    @Published var PHRASE: String
    @Published var TRANSLATION: String
    @Published var PHRASES = ""

    init(x: MUnitPhrase) {
        ID = "\(x.ID)"
        TEXTBOOKNAME = x.TEXTBOOKNAME
        UNITSTR = x.UNITSTR
        indexUNIT = x.textbook.arrUnits.firstIndex { $0.value == x.UNIT } ?? -1
        PARTSTR = x.PARTSTR
        indexPART = x.textbook.arrParts.firstIndex { $0.value == x.PART } ?? -1
        SEQNUM = String(x.SEQNUM)
        PHRASEID = "\(x.PHRASEID)"
        PHRASE = x.PHRASE
        TRANSLATION = x.TRANSLATION
    }

    func save(to x: MUnitPhrase) {
        if indexUNIT != -1 {
            x.UNIT = x.textbook.arrUnits[indexUNIT].value
        }
        if indexPART != -1 {
            x.PART = x.textbook.arrUnits[indexPART].value
        }
        x.SEQNUM = Int(SEQNUM)!
        x.PHRASE = PHRASE
        x.TRANSLATION = TRANSLATION
    }
}
