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
    var ID = 0
    var DICTID = 0
    var LANGIDFROM = 0
    var LANGNAMEFROM = ""
    var LANGIDTO = 0
    var LANGNAMETO = ""
    var SEQNUM = 0
    var DICTTYPEID = 0
    var DICTTYPENAME = ""
    var DICTNAME = ""
    var URL: String?
    var CHCONV: String?
    var AUTOMATION: String?
    var DICTTABLE: String?
    var TRANSFORM: String?
    var WAIT = 0
    var TEMPLATE: String?
    var TEMPLATE2: String?
    
    override var description: String { DICTNAME }

    func urlString(word: String, arrAutoCorrect: [MAutoCorrect]) -> String {
        let word2 = CHCONV == "BASIC" ? MAutoCorrect.autoCorrect(text: word, arrAutoCorrect: arrAutoCorrect, colFunc1: { $0.EXTENDED }, colFunc2: { $0.BASIC }) :
            word
        let url = URL!.replacingOccurrences(of: "{0}", with: word2.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        print(url)
        return url
    }
    
    static func getDictsByLang(_ langid: Int) -> Observable<[MDictionary]> {
        // SQL: SELECT * FROM VDICTIONARIES WHERE LANGIDFROM=?
        let url = "\(CommonApi.url)VDICTIONARIES?filter=LANGIDFROM,eq,\(langid)&order=SEQNUM&order=DICTNAME"
        return RestApi.getRecords(url: url)
    }

    static func update(item: MDictionary) -> Observable<()> {
        // SQL: UPDATE DICTIONARIES SET DICTID=?, LANGIDFROM=?, LANGIDTO=?, NAME=?, SEQNUM=?, DICTTYPEID=?, URL=?, CHCONV=?, AUTOMATION=?, AUTOJUMP=?, DICTTABLE=?, TEMPLATE=?, TEMPLATE2=? WHERE ID=?
        let url = "\(CommonApi.url)DICTIONARIES/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString(prettyPrint: false)!).map { print($0) }
    }
    
    static func create(item: MDictionary) -> Observable<Int> {
        // SQL: INSERT INTO DICTIONARIES (DICTID, LANGIDFROM, LANGIDTO, NAME, SEQNUM, DICTTYPEID, URL, CHCONV, AUTOMATION, AUTOJUMP, DICTTABLE, TEMPLATE, TEMPLATE2) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)
        let url = "\(CommonApi.url)DICTIONARIES"
        return RestApi.create(url: url, body: try! item.toJSONString(prettyPrint: false)!).map { $0.toInt()! }.do(onNext: { print($0) })
    }

    static func getDictsReferenceByLang(_ langid: Int) -> Observable<[MDictionary]> {
        // SQL: SELECT * FROM VDICTSREFERENCE WHERE LANGIDFROM=?
        let url = "\(CommonApi.url)VDICTSREFERENCE?filter=LANGIDFROM,eq,\(langid)&order=SEQNUM&order=DICTNAME"
        return RestApi.getRecords(url: url)
    }
    
    func htmlString(_ html: String, word: String, useTemplate2: Bool = false) -> String {
        let template = useTemplate2 && !(TEMPLATE2 ?? "").isEmpty ? TEMPLATE2! : TEMPLATE!
        return CommonApi.extractText(from: html, transform: TRANSFORM!, template: template) { (text, template) in
            let template = template.replacingOccurrences(of: "{0}", with: word)
                .replacingOccurrences(of: "{1}", with: CommonApi.cssFolder)
                .replacingOccurrences(of: "{2}", with: text as String)
            return template
        }
    }

    static func getDictsNoteByLang(_ langid: Int) -> Observable<[MDictionary]> {
        // SQL: SELECT * FROM VDICTSNOTE WHERE LANGIDFROM = ?
        let url = "\(CommonApi.url)VDICTSNOTE?filter=LANGIDFROM,eq,\(langid)"
        return RestApi.getRecords(url: url)
    }
    
    static func getDictsTranslationByLang(_ langid: Int) -> Observable<[MDictionary]> {
        // SQL: SELECT * FROM VDICTSTRANSLATION WHERE LANGIDFROM = ?
        let url = "\(CommonApi.url)VDICTSTRANSLATION?filter=LANGIDFROM,eq,\(langid)"
        return RestApi.getRecords(url: url)
    }
}

@objcMembers
class MDictType: NSObject, Codable {
    var CODE = 0
    var NAME = ""
    static func getData() -> Observable<[MDictType]> {
        // SQL: SELECT * FROM CODES WHERE KIND = 1
        let url = "\(CommonApi.url)CODES?filter=KIND,eq,1"
        return RestApi.getRecords(url: url)
    }
}
