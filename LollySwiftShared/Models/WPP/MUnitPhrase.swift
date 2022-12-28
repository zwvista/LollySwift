//
//  MUnitPhrase.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/07.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

@objcMembers
class MUnitPhrase: NSObject, Codable, MPhraseProtocol {
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

    static func getDataByTextbook(_ textbook: MTextbook, unitPartFrom: Int, unitPartTo: Int) -> Single<[MUnitPhrase]> {
        // SQL: SELECT * FROM VUNITPHRASES WHERE TEXTBOOKID=? AND UNITPART BETWEEN ? AND ? ORDER BY UNITPART,SEQNUM
        let url = "\(CommonApi.urlAPI)VUNITPHRASES?filter=TEXTBOOKID,eq,\(textbook.ID)&filter=UNITPART,bt,\(unitPartFrom),\(unitPartTo)&order=UNITPART&order=SEQNUM"
        let o: Single<[MUnitPhrase]> = RestApi.getRecords(url: url)
        return o.do(onSuccess: { arr in
            arr.forEach { $0.textbook = textbook }
        })
    }

    static func getDataByTextbook(_ textbook: MTextbook) -> Single<[MUnitPhrase]> {
        // SQL: SELECT * FROM VUNITPHRASES WHERE TEXTBOOKID=? ORDER BY PHRASEID
        let url = "\(CommonApi.urlAPI)VUNITPHRASES?filter=TEXTBOOKID,eq,\(textbook.ID)&order=PHRASEID"
        let o: Single<[MUnitPhrase]> = RestApi.getRecords(url: url)
        return o.do(onSuccess: { arr in
            arr.forEach { $0.textbook = textbook }
        })
    }

    private static func setTextbook(_ o: Single<[MUnitPhrase]>, arrTextbooks: [MTextbook]) -> Single<[MUnitPhrase]> {
        return o.map { arr in
            Dictionary(grouping: arr, by: \.PHRASEID).values.compactMap { $0[0] }
        }.do(onSuccess: { arr in
            arr.forEach { row in
                row.textbook = arrTextbooks.first { $0.ID == row.TEXTBOOKID }!
            }
        })
    }

    static func getDataByLang(_ langid: Int, arrTextbooks: [MTextbook]) -> Single<[MUnitPhrase]> {
        // SQL: SELECT * FROM VTEXTBOOKPHRASES WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)VUNITPHRASES?filter=LANGID,eq,\(langid)&order=TEXTBOOKID&order=UNIT&order=PART&order=SEQNUM"
        return setTextbook(RestApi.getRecords(url: url), arrTextbooks: arrTextbooks)
    }

    static func getDataById(_ id: Int, arrTextbooks: [MTextbook]) -> Single<MUnitPhrase?> {
        // SQL: SELECT * FROM VUNITPHRASES WHERE ID=?
        let url = "\(CommonApi.urlAPI)VUNITPHRASES?filter=ID,eq,\(id)"
        return setTextbook(RestApi.getRecords(url: url), arrTextbooks: arrTextbooks).map { $0.isEmpty ? nil : $0[0] }
    }

    static func getDataByLangPhrase(langid: Int, phrase: String, arrTextbooks: [MTextbook]) -> Single<[MUnitPhrase]> {
        // SQL: SELECT * FROM VUNITPHRASES WHERE LANGID=? AND PHRASE=?
        let url = "\(CommonApi.urlAPI)VUNITPHRASES?filter=LANGID,eq,\(langid)&filter=PHRASE,eq,\(phrase.urlEncoded())"
        // Api is case insensitive
        return setTextbook(RestApi.getRecords(url: url).map { $0.filter { $0.PHRASE == phrase } }, arrTextbooks: arrTextbooks)
    }

    static func update(_ id: Int, seqnum: Int) -> Single<()> {
        // SQL: UPDATE UNITPHRASES SET SEQNUM=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)UNITPHRASES/\(id)"
        let body = "SEQNUM=\(seqnum)"
        return RestApi.update(url: url, body: body).map { print($0) }
    }

    static func update(item: MUnitPhrase) -> Single<()> {
        // SQL: CALL UNITPHRASES_UPDATE
        let url = "\(CommonApi.urlSP)UNITPHRASES_UPDATE"
        let parameters = item.toParameters()
        return RestApi.callSP(url: url, parameters: parameters).map { print($0) }
    }

    static func create(item: MUnitPhrase) -> Single<Int> {
        // SQL: CALL UNITPHRASES_CREATE
        let url = "\(CommonApi.urlSP)UNITPHRASES_CREATE"
        let parameters = item.toParameters()
        return RestApi.callSP(url: url, parameters: parameters).map { print($0); return Int($0.NEW_ID!)! }
    }

    static func delete(item: MUnitPhrase) -> Single<()> {
        // SQL: CALL UNITPHRASES_DELETE
        let url = "\(CommonApi.urlSP)UNITPHRASES_DELETE"
        let parameters = item.toParameters()
        return RestApi.callSP(url: url, parameters: parameters).map { print($0) }
    }
}

class MUnitPhraseEdit {
    let ID: String
    let TEXTBOOKNAME: BehaviorRelay<String>
    let UNITSTR_: BehaviorRelay<String>
    var UNITSTR: String { get { UNITSTR_.value } set { UNITSTR_.accept(newValue) } }
    let indexUNIT_: BehaviorRelay<Int>
    var indexUNIT: Int { get { indexUNIT_.value } set { indexUNIT_.accept(newValue) } }
    let PARTSTR_: BehaviorRelay<String>
    var PARTSTR: String { get { PARTSTR_.value } set { PARTSTR_.accept(newValue) } }
    let indexPART_: BehaviorRelay<Int>
    var indexPART: Int { get { indexPART_.value } set { indexPART_.accept(newValue) } }
    let SEQNUM: BehaviorRelay<String>
    let PHRASEID: String
    let PHRASE: BehaviorRelay<String>
    let TRANSLATION: BehaviorRelay<String>
    let PHRASES = BehaviorRelay(value: "")

    init(x: MUnitPhrase) {
        ID = "\(x.ID)"
        TEXTBOOKNAME = BehaviorRelay(value: x.TEXTBOOKNAME)
        UNITSTR_ = BehaviorRelay(value: x.UNITSTR)
        indexUNIT_ = BehaviorRelay(value: x.textbook.arrUnits.firstIndex { $0.value == x.UNIT } ?? -1)
        PARTSTR_ = BehaviorRelay(value: x.PARTSTR)
        indexPART_ = BehaviorRelay(value: x.textbook.arrParts.firstIndex { $0.value == x.PART } ?? -1)
        SEQNUM = BehaviorRelay(value: String(x.SEQNUM))
        PHRASEID = "\(x.PHRASEID)"
        PHRASE = BehaviorRelay(value: x.PHRASE)
        TRANSLATION = BehaviorRelay(value: x.TRANSLATION)
    }

    func save(to x: MUnitPhrase) {
        if indexUNIT != -1 {
            x.UNIT = x.textbook.arrUnits[indexUNIT].value
        }
        if indexPART != -1 {
            x.PART = x.textbook.arrUnits[indexPART].value
        }
        x.SEQNUM = Int(SEQNUM.value)!
        x.PHRASE = PHRASE.value
        x.TRANSLATION = TRANSLATION.value
    }
}
