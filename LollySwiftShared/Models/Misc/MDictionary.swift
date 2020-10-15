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
    dynamic var URL: String?
    dynamic var CHCONV: String?
    dynamic var AUTOMATION: String?
    dynamic var TRANSFORM: String?
    dynamic var WAIT = 0
    dynamic var TEMPLATE: String?
    dynamic var TEMPLATE2: String?
    
    override var description: String { DICTNAME }

    func urlString(word: String, arrAutoCorrect: [MAutoCorrect]) -> String {
        let word2 = CHCONV == "BASIC" ? MAutoCorrect.autoCorrect(text: word, arrAutoCorrect: arrAutoCorrect, colFunc1: { $0.EXTENDED }, colFunc2: { $0.BASIC }) :
            word
        let url = URL!.replacingOccurrences(of: "{0}", with: word2.urlEncoded())
        print(url)
        return url
    }
    
    static func getDictsByLang(_ langid: Int) -> Observable<[MDictionary]> {
        // SQL: SELECT * FROM VDICTIONARIES WHERE LANGIDFROM=?
        let url = "\(CommonApi.urlAPI)VDICTIONARIES?filter=LANGIDFROM,eq,\(langid)&order=SEQNUM&order=DICTNAME"
        return RestApi.getRecords(url: url)
    }

    static func getDictsReferenceByLang(_ langid: Int) -> Observable<[MDictionary]> {
        // SQL: SELECT * FROM VDICTSREFERENCE WHERE LANGIDFROM=?
        let url = "\(CommonApi.urlAPI)VDICTSREFERENCE?filter=LANGIDFROM,eq,\(langid)&order=SEQNUM&order=DICTNAME"
        return RestApi.getRecords(url: url)
    }
    
    func htmlString(_ html: String, word: String, useTemplate2: Bool = false) -> String {
        let template = useTemplate2 && !(TEMPLATE2 ?? "").isEmpty ? TEMPLATE2! : TEMPLATE!
        return CommonApi.extractText(from: html, transform: TRANSFORM!, template: template) { (text, template) in CommonApi.applyTemplate(template: template, word: word, text: text)
        }
    }

    static func getDictsNoteByLang(_ langid: Int) -> Observable<[MDictionary]> {
        // SQL: SELECT * FROM VDICTSNOTE WHERE LANGIDFROM = ?
        let url = "\(CommonApi.urlAPI)VDICTSNOTE?filter=LANGIDFROM,eq,\(langid)"
        return RestApi.getRecords(url: url)
    }
    
    static func getDictsTranslationByLang(_ langid: Int) -> Observable<[MDictionary]> {
        // SQL: SELECT * FROM VDICTSTRANSLATION WHERE LANGIDFROM = ?
        let url = "\(CommonApi.urlAPI)VDICTSTRANSLATION?filter=LANGIDFROM,eq,\(langid)"
        return RestApi.getRecords(url: url)
    }
}

@objcMembers
class MDictionaryDict: NSObject, Codable {
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
    dynamic var URL: String?
    dynamic var CHCONV: String?
    dynamic var AUTOMATION: String?
    dynamic var TRANSFORM: String?
    dynamic var WAIT = 0
    dynamic var TEMPLATE: String?
    dynamic var TEMPLATE2: String?

    static func update(item: MDictionary) -> Observable<()> {
        // SQL: UPDATE DICTIONARIES SET DICTID=?, LANGIDFROM=?, LANGIDTO=?, NAME=?, SEQNUM=?, DICTTYPECODE=?, URL=?, CHCONV=?, AUTOMATION=?, AUTOJUMP=?, DICTTABLE=?, TEMPLATE=?, TEMPLATE2=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)DICTIONARIES/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString()!).map { print($0) }
    }
    
    static func create(item: MDictionary) -> Observable<Int> {
        // SQL: INSERT INTO DICTIONARIES (DICTID, LANGIDFROM, LANGIDTO, NAME, SEQNUM, DICTTYPECODE, URL, CHCONV, AUTOMATION, AUTOJUMP, DICTTABLE, TEMPLATE, TEMPLATE2) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)
        let url = "\(CommonApi.urlAPI)DICTIONARIES"
        return RestApi.create(url: url, body: try! item.toJSONString()!).map { $0.toInt()! }.do(onNext: { print($0) })
    }
}

@objcMembers
class MDictionarySite: NSObject, Codable {
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
    dynamic var URL: String?
    dynamic var CHCONV: String?
    dynamic var AUTOMATION: String?
    dynamic var TRANSFORM: String?
    dynamic var WAIT = 0
    dynamic var TEMPLATE: String?
    dynamic var TEMPLATE2: String?
    
    static func update(item: MDictionary) -> Observable<()> {
        // SQL: UPDATE SITES SET DICTID=?, LANGIDFROM=?, LANGIDTO=?, NAME=?, SEQNUM=?, DICTTYPECODE=?, URL=?, CHCONV=?, AUTOMATION=?, AUTOJUMP=?, DICTTABLE=?, TEMPLATE=?, TEMPLATE2=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)SITES/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString()!).map { print($0) }
    }
    
    static func create(item: MDictionary) -> Observable<Int> {
        // SQL: INSERT INTO SITES (DICTID, LANGIDFROM, LANGIDTO, NAME, SEQNUM, DICTTYPECODE, URL, CHCONV, AUTOMATION, AUTOJUMP, DICTTABLE, TEMPLATE, TEMPLATE2) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)
        let url = "\(CommonApi.urlAPI)SITES"
        return RestApi.create(url: url, body: try! item.toJSONString()!).map { $0.toInt()! }.do(onNext: { print($0) })
    }
}
