//
//  MUnitPhrase.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/07.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

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
    dynamic var TRANSLATION: String?

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
    var UNITPARTSEQNUM: String { "\(UNITSTR) \(SEQNUM)\n\(PARTSTR)" }
    
    func copy(from x: MUnitPhrase) {
        ID = x.ID
        LANGID = x.LANGID
        TEXTBOOKID = x.TEXTBOOKID
        TEXTBOOKNAME = x.TEXTBOOKNAME
        UNIT = x.UNIT
        PART = x.PART
        SEQNUM = x.SEQNUM
        PHRASEID = x.PHRASEID
        PHRASE = x.PHRASE
        TRANSLATION = x.TRANSLATION
        textbook = x.textbook
    }

    static func getDataByTextbook(_ textbook: MTextbook, unitPartFrom: Int, unitPartTo: Int) -> Observable<[MUnitPhrase]> {
        // SQL: SELECT * FROM VUNITPHRASES WHERE TEXTBOOKID=? AND UNITPART BETWEEN ? AND ? ORDER BY UNITPART,SEQNUM
        let url = "\(CommonApi.urlAPI)VUNITPHRASES?filter=TEXTBOOKID,eq,\(textbook.ID)&filter=UNITPART,bt,\(unitPartFrom),\(unitPartTo)&order=UNITPART&order=SEQNUM"
        let o: Observable<[MUnitPhrase]> = RestApi.getRecords(url: url)
        return o.do(onNext: { arr in
            arr.forEach { $0.textbook = textbook }
        })
    }

    static func getDataByLang(_ langid: Int, arrTextbooks: [MTextbook]) -> Observable<[MUnitPhrase]> {
        // SQL: SELECT * FROM VTEXTBOOKPHRASES WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)VUNITPHRASES?filter=LANGID,eq,\(langid)&order=TEXTBOOKID&order=UNIT&order=PART&order=SEQNUM"
        let o: Observable<[MUnitPhrase]> = RestApi.getRecords(url: url)
        return o.do(onNext: { arr in
            arr.forEach { row in
                row.textbook = arrTextbooks.first { $0.ID == row.TEXTBOOKID }!
            }
        })
    }

    static func getDataByPhraseId(_ phraseid: Int) -> Observable<[MUnitPhrase]> {
        // SQL: SELECT * FROM VUNITPHRASES WHERE PHRASEID=?
        let url = "\(CommonApi.urlAPI)VUNITPHRASES?filter=PHRASEID,eq,\(phraseid)"
        return RestApi.getRecords(url: url)
    }

    static func getDataByLangPhrase(langid: Int, phrase: String, arrTextbooks: [MTextbook]) -> Observable<[MUnitPhrase]> {
        // SQL: SELECT * FROM VUNITPHRASES WHERE LANGID=? AND PHRASE=?
        let url = "\(CommonApi.urlAPI)VUNITPHRASES?filter=LANGID,eq,\(langid)&filter=PHRASE,eq,\(phrase.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
        // Api is case insensitive
        let o: Observable<[MUnitPhrase]> = RestApi.getRecords(url: url).map { $0.filter { $0.PHRASE == phrase } }
        return o.do(onNext: { arr in
            arr.forEach { row in
                row.textbook = arrTextbooks.first { $0.ID == row.TEXTBOOKID }!
            }
        })
    }

    static func update(_ id: Int, seqnum: Int) -> Observable<()> {
        // SQL: UPDATE UNITPHRASES SET SEQNUM=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)UNITPHRASES/\(id)"
        let body = "SEQNUM=\(seqnum)"
        return RestApi.update(url: url, body: body).map { print($0) }
    }
    
    static func update(item: MUnitPhrase) -> Observable<()> {
        // SQL: UPDATE UNITPHRASES SET UNIT=?, PART=?, SEQNUM=?, PHRASEID=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)UNITPHRASES/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString()!).map { print($0) }
    }

    static func create(item: MUnitPhrase) -> Observable<Int> {
        // SQL: INSERT INTO UNITPHRASES (TEXTBOOKID, UNIT, PART, SEQNUM, PHRASEID) VALUES (?,?,?,?,?)
        let url = "\(CommonApi.urlAPI)UNITPHRASES"
        return RestApi.create(url: url, body: try! item.toJSONString()!).map { $0.toInt()! }.do(onNext: { print($0) })
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        // SQL: DELETE UNITPHRASES WHERE ID=?
        let url = "\(CommonApi.urlAPI)UNITPHRASES/\(id)"
        return RestApi.delete(url: url).map { print($0) }
    }
    
    static func deleteByPhraseId(_ phraseid: Int) -> Observable<()> {
        // SQL: DELETE UNITPHRASES WHERE PHRASEID=?
        return getDataByPhraseId(phraseid).flatMap { arr -> Observable<()> in
            if arr.isEmpty {
                return Observable.empty()
            } else {
                let ids = arr.map { $0.ID.description }.joined(separator: ",")
                let url = "\(CommonApi.urlAPI)UNITPHRASES/\(ids)"
                return RestApi.delete(url: url).map { print($0) }
            }
        }
    }
}
