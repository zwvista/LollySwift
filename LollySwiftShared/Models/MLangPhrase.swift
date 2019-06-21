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
class MLangPhrase: NSObject, Codable, MPhraseProtocol {
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
        let url = "\(CommonApi.url)LANGPHRASES?filter=LANGID,eq,\(langid)&order=PHRASE"
        return RestApi.getRecords(url: url)
    }

    static func getDataByLangPhrase(langid: Int, phrase: String) -> Observable<[MLangPhrase]> {
        // SQL: SELECT * FROM LANGPHRASES WHERE LANGID=? AND PHRASE=?
        let url = "\(CommonApi.url)LANGPHRASES?filter=LANGID,eq,\(langid)&filter=PHRASE,eq,\(phrase.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
        // Api is case insensitive
        return RestApi.getRecords(url: url).map { $0.filter { $0.PHRASE == phrase } }
    }
    
    static func getDataById(_ id: Int) -> Observable<[MLangPhrase]> {
        // SQL: SELECT * FROM LANGPHRASES WHERE ID=?
        let url = "\(CommonApi.url)LANGPHRASES?filter=ID,eq,\(id)"
        return RestApi.getRecords(url: url)
    }

    static func update(_ id: Int, translation: String) -> Observable<()> {
        // SQL: UPDATE LANGPHRASES SET TRANSLATION=? WHERE ID=?
        let url = "\(CommonApi.url)LANGPHRASES/\(id)"
        let body = "TRANSLATION=\(translation)"
        return RestApi.update(url: url, body: body).map { print($0) }
    }
    
    static func update(item: MLangPhrase) -> Observable<()> {
        // SQL: UPDATE LANGPHRASES SET PHRASE=?, TRANSLATION=? WHERE ID=?
        let url = "\(CommonApi.url)LANGPHRASES/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString(prettyPrint: false)!).map { print($0) }
    }

    static func create(item: MLangPhrase) -> Observable<Int> {
        // SQL: INSERT INTO LANGPHRASES (LANGID, PHRASE, TRANSLATION) VALUES (?,?,?)
        let url = "\(CommonApi.url)LANGPHRASES"
        return RestApi.create(url: url, body: try! item.toJSONString(prettyPrint: false)!).map { $0.toInt()! }.do(onNext: { print($0) })
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        // SQL: DELETE LANGPHRASES WHERE ID=?
        let url = "\(CommonApi.url)LANGPHRASES/\(id)"
        return RestApi.delete(url: url).map { print($0) }
    }
}
