//
//  MDictionary.swift
//  LollySwiftShared
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
class MDictionary: NSObject, Codable {
    dynamic var ID = 0
    dynamic var DICTID = 0
    dynamic var LANGIDFROM = 0
    dynamic var LANGNAMEFROM = ""
    dynamic var LANGIDTO = 0
    dynamic var LANGNAMETO = ""
    dynamic var SEQNUM = 0
    dynamic var DICTTYPECODE = 0
    dynamic var DICTTYPENAME = ""
    dynamic var DICTNAME = ""
    dynamic var URL = ""
    dynamic var CHCONV = ""
    dynamic var AUTOMATION = ""
    dynamic var TRANSFORM = ""
    dynamic var WAIT = 0
    dynamic var TEMPLATE = ""
    dynamic var TEMPLATE2 = ""

    enum CodingKeys : String, CodingKey {
        case ID
        case DICTID
        case LANGIDFROM
        case LANGNAMEFROM
        case LANGIDTO
        case LANGNAMETO
        case SEQNUM
        case DICTTYPECODE
        case DICTTYPENAME
        case DICTNAME = "NAME"
        case URL
        case CHCONV
        case AUTOMATION
        case TRANSFORM
        case WAIT
        case TEMPLATE
        case TEMPLATE2
    }

    override var description: String { DICTNAME }

    func urlString(word: String, arrAutoCorrect: [MAutoCorrect]) -> String {
        let word2 = CHCONV == "BASIC" ? MAutoCorrect.autoCorrect(text: word, arrAutoCorrect: arrAutoCorrect, colFunc1: \.EXTENDED, colFunc2: \.BASIC) : word
        let url = URL.replacingOccurrences(of: "{0}", with: word2.urlEncoded())
        print(url)
        return url
    }

    static func getDictsByLang(_ langid: Int) -> Single<[MDictionary]> {
        // SQL: SELECT * FROM VDICTIONARIES WHERE LANGIDFROM=?
        let url = "\(CommonApi.urlAPI)VDICTIONARIES?filter=LANGIDFROM,eq,\(langid)&order=SEQNUM&order=DICTNAME"
        return RestApi.getRecords(url: url)
    }

    static func getDictsReferenceByLang(_ langid: Int) -> Single<[MDictionary]> {
        // SQL: SELECT * FROM VDICTSREFERENCE WHERE LANGIDFROM=?
        let url = "\(CommonApi.urlAPI)VDICTSREFERENCE?filter=LANGIDFROM,eq,\(langid)&order=SEQNUM&order=DICTNAME"
        return RestApi.getRecords(url: url)
    }

    func htmlString(_ html: String, word: String, useTemplate2: Bool = false) -> String {
        let template = useTemplate2 && !TEMPLATE2.isEmpty ? TEMPLATE2 : TEMPLATE
        return CommonApi.extractText(from: html, transform: TRANSFORM, template: template) { (text, template) in CommonApi.applyTemplate(template: template, word: word, text: text)
        }
    }

    static func getDictsNoteByLang(_ langid: Int) -> Single<[MDictionary]> {
        // SQL: SELECT * FROM VDICTSNOTE WHERE LANGIDFROM = ?
        let url = "\(CommonApi.urlAPI)VDICTSNOTE?filter=LANGIDFROM,eq,\(langid)"
        return RestApi.getRecords(url: url)
    }

    static func getDictsTranslationByLang(_ langid: Int) -> Single<[MDictionary]> {
        // SQL: SELECT * FROM VDICTSTRANSLATION WHERE LANGIDFROM = ?
        let url = "\(CommonApi.urlAPI)VDICTSTRANSLATION?filter=LANGIDFROM,eq,\(langid)"
        return RestApi.getRecords(url: url)
    }

    static func update(item: MDictionary) -> Single<()> {
        // SQL: UPDATE DICTIONARIES SET DICTID=?, LANGIDFROM=?, LANGIDTO=?, NAME=?, SEQNUM=?, DICTTYPECODE=?, URL=?, CHCONV=?, AUTOMATION=?, AUTOJUMP=?, DICTTABLE=?, TRANSFORM=?, WAIT=?, TEMPLATE=?, TEMPLATE2=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)DICTIONARIES/\(item.ID)"
        return RestApi.update(url: url, body: item.toParameters(isSP: false)).map { print($0) }
    }

    static func create(item: MDictionary) -> Single<Int> {
        // SQL: INSERT INTO DICTIONARIES (DICTID, LANGIDFROM, LANGIDTO, NAME, SEQNUM, DICTTYPECODE, URL, CHCONV, AUTOMATION, AUTOJUMP, DICTTABLE, TRANSFORM, WAIT, TEMPLATE, TEMPLATE2) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)
        let url = "\(CommonApi.urlAPI)DICTIONARIES"
        return RestApi.create(url: url, body: item.toParameters(isSP: false)).map { Int($0)! }.do(onSuccess: { print($0) })
    }
}
