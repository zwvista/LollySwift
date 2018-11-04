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
    var LANGIDFROM: Int?
    var DICTTYPENAME: String?
    var DICTNAME: String?
    var URL: String?
    var CHCONV: String?
    var TRANSFORM: String?
    var WAIT: Int?
    var TEMPLATE: String?
    
    func urlString(word: String, arrAutoCorrect: [MAutoCorrect]) -> String {
        let word2 = CHCONV == "BASIC" ? MAutoCorrect.autoCorrect(text: word, arrAutoCorrect: arrAutoCorrect, colFunc1: { $0.EXTENDED }, colFunc2: { $0.BASIC }) :
            word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL!.replacingOccurrences(of: "{0}", with: word2)
        print(url)
        return url
    }
}

class MDictOnline : MDictionary {
    static func getDataByLang(_ langid: Int) -> Observable<[MDictOnline]> {
        // SQL: SELECT * FROM VDICTSONLINE WHERE LANGIDFROM = ?
        let url = "\(RestApi.url)VDICTSONLINE?transform=1&filter=LANGIDFROM,eq,\(langid)"
        return RestApi.getArray(url: url, keyPath: "VDICTSONLINE")
    }
    
    fileprivate let debugExtract = false
    
    func htmlString(_ html: String, word: String) -> String {
        return HtmlApi.extractText(from: html, transform: TRANSFORM!, template: TEMPLATE!) { (text, template) in
            
            //            var newTemplate = NSMutableString(string: template)
            //            regex = try! NSRegularExpression(pattern: "\\{\\d\\}")
            //            regex.replaceMatches(in: newTemplate, range: NSMakeRange(0, newTemplate.length), withTemplate: "%@")
            //            text = NSMutableString(format: newTemplate, word, "", text, RestApi.cssFolder)
            
            let template = template.replacingOccurrences(of: "{0}", with: word)
                .replacingOccurrences(of: "{1}", with: RestApi.cssFolder)
                .replacingOccurrences(of: "{2}", with: text as String)
            return NSMutableString(string: template)
        }
    }
}

class MDictOffline : MDictionary {
}

class MDictNote : MDictionary {
    static func getDataByLang(_ langid: Int) -> Observable<[MDictNote]> {
        // SQL: SELECT * FROM VDICTSNOTE WHERE LANGIDFROM = ?
        let url = "\(RestApi.url)VDICTSNOTE?transform=1&filter=LANGIDFROM,eq,\(langid)"
        return RestApi.getArray(url: url, keyPath: "VDICTSNOTE")
    }
}
