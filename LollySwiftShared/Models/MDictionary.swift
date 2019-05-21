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
    var DICTTYPENAME = ""
    var DICTNAME = ""
    var URL: String?
    var CHCONV: String?
    var TRANSFORM: String?
    var WAIT: Int?
    var TEMPLATE: String?
    var TEMPLATE2: String?
    
    override var description: String {
        return DICTNAME
    }

    func urlString(word: String, arrAutoCorrect: [MAutoCorrect]) -> String {
        let word2 = CHCONV == "BASIC" ? MAutoCorrect.autoCorrect(text: word, arrAutoCorrect: arrAutoCorrect, colFunc1: { $0.EXTENDED }, colFunc2: { $0.BASIC }) :
            word
        let url = URL!.replacingOccurrences(of: "{0}", with: word2.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        print(url)
        return url
    }
}

class MDictReference: MDictionary {
    static func getDataByLang(_ langid: Int) -> Observable<[MDictReference]> {
        // SQL: SELECT * FROM VDICTSREFERENCE WHERE LANGIDFROM=?
        let url = "\(CommonApi.url)VDICTSREFERENCE?transform=1&filter=LANGIDFROM,eq,\(langid)&order[]=SEQNUM&order[]=DICTNAME"
        return RestApi.getArray(url: url, keyPath: "VDICTSREFERENCE")
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
}

@objcMembers
class MDictItem: NSObject {
    var DICTID = ""
    var DICTNAME = ""
    
    override var description: String {
        return DICTNAME
    }

    init(id: String, name: String) {
        DICTID = id
        DICTNAME = name
        super.init()
    }
    
    func dictids() -> [String] {
        return DICTID.split(",")
    }
}

class MDictNote: MDictionary {
    static func getDataByLang(_ langid: Int) -> Observable<[MDictNote]> {
        // SQL: SELECT * FROM VDICTSNOTE WHERE LANGIDFROM = ?
        let url = "\(CommonApi.url)VDICTSNOTE?transform=1&filter=LANGIDFROM,eq,\(langid)"
        return RestApi.getArray(url: url, keyPath: "VDICTSNOTE")
    }
}

class MDictTranslation: MDictionary {
    static func getDataByLang(_ langid: Int) -> Observable<[MDictTranslation]> {
        // SQL: SELECT * FROM VDICTSTRANSLATION WHERE LANGIDFROM = ?
        let url = "\(CommonApi.url)VDICTSTRANSLATION?transform=1&filter=LANGIDFROM,eq,\(langid)"
        return RestApi.getArray(url: url, keyPath: "VDICTSTRANSLATION")
    }
}
