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
    var LANGIDFROM: Int?
    var DICTTYPENAME: String?
    var DICTNAME: String?
    var URL: String?
    var CHCONV: String?
    var TRANSFORM: String?
    var WAIT: Int?
    var TEMPLATE: String?
    var TEMPLATE2: String?

    func urlString(word: String, arrAutoCorrect: [MAutoCorrect]) -> String {
        let word2 = CHCONV == "BASIC" ? MAutoCorrect.autoCorrect(text: word, arrAutoCorrect: arrAutoCorrect, colFunc1: { $0.EXTENDED }, colFunc2: { $0.BASIC }) :
            word
        let url = URL!.replacingOccurrences(of: "{0}", with: word2.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        print(url)
        return url
    }
}

class MDictMean : MDictionary {
    static func getDataByLang(_ langid: Int) -> Observable<[MDictMean]> {
        // SQL: SELECT * FROM VDICTSMEAN WHERE LANGIDFROM=?
        let url = "\(RestApi.url)VDICTSMEAN?transform=1&filter=LANGIDFROM,eq,\(langid)"
        return RestApi.getArray(url: url, keyPath: "VDICTSMEAN")
    }
    
    func htmlString(_ html: String, word: String, useTemplate2: Bool = false) -> String {
        let template = useTemplate2 && !(TEMPLATE2 ?? "").isEmpty ? TEMPLATE2! : TEMPLATE!
        return HtmlApi.extractText(from: html, transform: TRANSFORM!, template: template) { (text, template) in
            let template = template.replacingOccurrences(of: "{0}", with: word)
                .replacingOccurrences(of: "{1}", with: RestApi.cssFolder)
                .replacingOccurrences(of: "{2}", with: text as String)
            return template
        }
    }
}

@objcMembers
class MDictGroup : NSObject {
    var DICTID = ""
    var DICTNAME = ""
    
    init(id: String, name: String) {
        DICTID = id
        DICTNAME = name
        super.init()
    }
    
    func dictids() -> [String] {
        return DICTID.split(",")
    }
}

class MDictNote : MDictionary {
    static func getDataByLang(_ langid: Int) -> Observable<[MDictNote]> {
        // SQL: SELECT * FROM VDICTSNOTE WHERE LANGIDFROM = ?
        let url = "\(RestApi.url)VDICTSNOTE?transform=1&filter=LANGIDFROM,eq,\(langid)"
        return RestApi.getArray(url: url, keyPath: "VDICTSNOTE")
    }
}
