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

    static func getDataByTextbook(_ textbook: MTextbook, unitPartFrom: Int, unitPartTo: Int) -> Observable<[MUnitPhrase]> {
        // SQL: SELECT * FROM VUNITPHRASES WHERE TEXTBOOKID=? AND UNITPART BETWEEN ? AND ? ORDER BY UNITPART,SEQNUM
        let url = "\(CommonApi.urlAPI)VUNITPHRASES?filter=TEXTBOOKID,eq,\(textbook.ID)&filter=UNITPART,bt,\(unitPartFrom),\(unitPartTo)&order=UNITPART&order=SEQNUM"
        let o: Observable<[MUnitPhrase]> = RestApi.getRecords(url: url)
        return o.do(onNext: { arr in
            arr.forEach { $0.textbook = textbook }
        })
    }
    
    static func getDataByTextbook(_ textbook: MTextbook) -> Observable<[MUnitPhrase]> {
        // SQL: SELECT * FROM VUNITPHRASES WHERE TEXTBOOKID=? ORDER BY PHRASEID
        let url = "\(CommonApi.urlAPI)VUNITPHRASES?filter=TEXTBOOKID,eq,\(textbook.ID)&order=PHRASEID"
        let o: Observable<[MUnitPhrase]> = RestApi.getRecords(url: url)
        return o.do(onNext: { arr in
            arr.forEach { $0.textbook = textbook }
        })
    }

    private static func setTextbook(_ o: Observable<[MUnitPhrase]>, arrTextbooks: [MTextbook]) -> Observable<[MUnitPhrase]> {
        return o.map { arr in
            Dictionary(grouping: arr) { $0.PHRASEID }.values.compactMap { $0[0] }
        }.do(onNext: { arr in
            arr.forEach { row in
                row.textbook = arrTextbooks.first { $0.ID == row.TEXTBOOKID }!
            }
        })
    }

    static func getDataByLang(_ langid: Int, arrTextbooks: [MTextbook]) -> Observable<[MUnitPhrase]> {
        // SQL: SELECT * FROM VTEXTBOOKPHRASES WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)VUNITPHRASES?filter=LANGID,eq,\(langid)&order=TEXTBOOKID&order=UNIT&order=PART&order=SEQNUM"
        return setTextbook(RestApi.getRecords(url: url), arrTextbooks: arrTextbooks)
    }
    
    static func getDataById(_ id: Int, arrTextbooks: [MTextbook]) -> Observable<MUnitPhrase?> {
        // SQL: SELECT * FROM VUNITPHRASES WHERE ID=?
        let url = "\(CommonApi.urlAPI)VUNITPHRASES?filter=ID,eq,\(id)"
        return setTextbook(RestApi.getRecords(url: url), arrTextbooks: arrTextbooks).map { $0.isEmpty ? nil : $0[0] }
    }

    static func getDataByLangPhrase(langid: Int, phrase: String, arrTextbooks: [MTextbook]) -> Observable<[MUnitPhrase]> {
        // SQL: SELECT * FROM VUNITPHRASES WHERE LANGID=? AND PHRASE=?
        let url = "\(CommonApi.urlAPI)VUNITPHRASES?filter=LANGID,eq,\(langid)&filter=PHRASE,eq,\(phrase.urlEncoded())"
        // Api is case insensitive
        return setTextbook(RestApi.getRecords(url: url).map { $0.filter { $0.PHRASE == phrase } }, arrTextbooks: arrTextbooks)
    }

    static func update(_ id: Int, seqnum: Int) -> Observable<()> {
        // SQL: UPDATE UNITPHRASES SET SEQNUM=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)UNITPHRASES/\(id)"
        let body = "SEQNUM=\(seqnum)"
        return RestApi.update(url: url, body: body).map { print($0) }
    }
    
    static func update(item: MUnitPhrase) -> Observable<()> {
        // SQL: CALL UNITPHRASES_UPDATE
        let url = "\(CommonApi.urlSP)UNITPHRASES_UPDATE"
        let parameters = try! item.toParameters()
        return RestApi.callSP(url: url, parameters: parameters).map { print($0) }
    }

    static func create(item: MUnitPhrase) -> Observable<Int> {
        // SQL: CALL UNITPHRASES_CREATE
        let url = "\(CommonApi.urlSP)UNITPHRASES_CREATE"
        let parameters = try! item.toParameters()
        return RestApi.callSP(url: url, parameters: parameters).map { print($0); return $0.NEW_ID!.toInt()! }
    }
    
    static func delete(item: MUnitPhrase) -> Observable<()> {
        // SQL: CALL UNITPHRASES_DELETE
        let url = "\(CommonApi.urlSP)UNITPHRASES_DELETE"
        let parameters = try! item.toParameters()
        return RestApi.callSP(url: url, parameters: parameters).map { print($0) }
    }
}

class MUnitPhraseEdit {
    var ID: BehaviorRelay<String>
    var TEXTBOOKNAME: BehaviorRelay<String>
    var UNITSTR: BehaviorRelay<String>
    var indexUNIT: BehaviorRelay<Int>
    var PARTSTR: BehaviorRelay<String>
    var indexPART: BehaviorRelay<Int>
    var SEQNUM: BehaviorRelay<String>
    var PHRASEID: BehaviorRelay<String>
    var PHRASE: BehaviorRelay<String>
    var TRANSLATION: BehaviorRelay<String>

    init(x: MUnitPhrase) {
        ID = BehaviorRelay(value: x.ID.toString)
        TEXTBOOKNAME = BehaviorRelay(value: x.TEXTBOOKNAME)
        UNITSTR = BehaviorRelay(value: x.UNITSTR)
        indexUNIT = BehaviorRelay(value: x.textbook.arrUnits.firstIndex { $0.value == x.UNIT } ?? -1)
        PARTSTR = BehaviorRelay(value: x.PARTSTR)
        indexPART = BehaviorRelay(value: x.textbook.arrParts.firstIndex { $0.value == x.PART } ?? -1)
        SEQNUM = BehaviorRelay(value: x.SEQNUM.toString)
        PHRASEID = BehaviorRelay(value: x.PHRASEID.toString)
        PHRASE = BehaviorRelay(value: x.PHRASE)
        TRANSLATION = BehaviorRelay(value: x.TRANSLATION)
    }
    
    func save(to x: MUnitPhrase) {
        if indexUNIT.value != -1 {
            x.UNIT = x.textbook.arrUnits[indexUNIT.value].value
        }
        if indexPART.value != -1 {
            x.PART = x.textbook.arrUnits[indexPART.value].value
        }
        x.SEQNUM = SEQNUM.value.toInt()!
        x.PHRASE = PHRASE.value
        x.TRANSLATION = TRANSLATION.value
    }
}
