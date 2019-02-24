//
//  MLangPhrase.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/07.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
class MLangPhrase: NSObject, Codable {
    var ID = 0
    var LANGID = 0
    var PHRASE = ""
    var TRANSLATION: String?
    
    override init() {
    }
    
    init(unititem: MUnitPhrase) {
        ID = unititem.PHRASEID
        LANGID = unititem.LANGID
        PHRASE = unititem.PHRASE
        TRANSLATION = unititem.TRANSLATION
        super.init()
    }
    
    init(textbookitem: MTextbookPhrase) {
        ID = textbookitem.PHRASEID
        LANGID = textbookitem.LANGID
        PHRASE = textbookitem.PHRASE
        TRANSLATION = textbookitem.TRANSLATION
        super.init()
    }

    func combineTranslation(_ translation: String?) -> Bool {
        let oldTranslation = TRANSLATION
        if !(translation ?? "").isEmpty {
            if (TRANSLATION ?? "").isEmpty {
                TRANSLATION = translation
            } else {
                var arr = TRANSLATION!.split(",")
                if !arr.contains(translation!) {
                    arr.append(translation!)
                    TRANSLATION = arr.joined(separator: ",")
                }
            }
        }
        return oldTranslation != TRANSLATION
    }

    static func getDataByLang(_ langid: Int) -> Observable<[MLangPhrase]> {
        // SQL: SELECT * FROM LANGPHRASES WHERE LANGID=?
        let url = "\(RestApi.url)LANGPHRASES?transform=1&filter=LANGID,eq,\(langid)&order=PHRASE"
        return RestApi.getArray(url: url, keyPath: "LANGPHRASES")
    }

    static func getDataByLangPhrase(langid: Int, phrase: String) -> Observable<[MLangPhrase]> {
        // SQL: SELECT * FROM LANGPHRASES WHERE LANGID=? AND PHRASE=?
        let url = "\(RestApi.url)LANGPHRASES?transform=1&filter[]=LANGID,eq,\(langid)&filter[]=PHRASE,eq,\(phrase.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
        // Api is case insensitive
        return RestApi.getArray(url: url, keyPath: "LANGPHRASES").map { $0.filter { $0.PHRASE == phrase } }
    }
    
    static func getDataById(_ id: Int) -> Observable<[MLangPhrase]> {
        // SQL: SELECT * FROM LANGPHRASES WHERE ID=?
        let url = "\(RestApi.url)LANGPHRASES?transform=1&filter=ID,eq,\(id)"
        return RestApi.getArray(url: url, keyPath: "LANGPHRASES")
    }

    static func update(_ id: Int, translation: String) -> Observable<String> {
        // SQL: UPDATE LANGPHRASES SET TRANSLATION=? WHERE ID=?
        let url = "\(RestApi.url)LANGPHRASES/\(id)"
        let body = "TRANSLATION=\(translation)"
        return RestApi.update(url: url, body: body)
    }

    static func update(_ id: Int, item: MLangPhrase) -> Observable<String> {
        // SQL: UPDATE LANGPHRASES SET PHRASE=?, TRANSLATION=? WHERE ID=?
        let url = "\(RestApi.url)LANGPHRASES/\(id)"
        return RestApi.update(url: url, body: try! item.toJSONString(prettyPrint: false)!)
    }
    
    static func update(item: MLangPhrase) -> Observable<String> {
        // SQL: UPDATE LANGPHRASES SET PHRASE=?, TRANSLATION=? WHERE ID=?
        let url = "\(RestApi.url)LANGPHRASES/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString(prettyPrint: false)!)
    }

    static func create(item: MLangPhrase) -> Observable<Int> {
        // SQL: INSERT INTO LANGPHRASES (LANGID, PHRASE, TRANSLATION) VALUES (?,?,?)
        let url = "\(RestApi.url)LANGPHRASES"
        return RestApi.create(url: url, body: try! item.toJSONString(prettyPrint: false)!).map {
            return $0.toInt()!
        }
    }
    
    static func delete(_ id: Int) -> Observable<String> {
        // SQL: DELETE LANGPHRASES WHERE ID=?
        let url = "\(RestApi.url)LANGPHRASES/\(id)"
        return RestApi.delete(url: url)
    }
}
