//
//  MLangPhrase.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/07.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

@objcMembers
class MLangPhrase: NSObject, Codable, MPhraseProtocol {
    dynamic var ID = 0
    dynamic var PHRASEID: Int { ID }
    dynamic var LANGID = 0
    dynamic var PHRASE = ""
    dynamic var TRANSLATION = ""
    
    override init() {
    }
    
    init(unititem: MUnitPhrase) {
        ID = unititem.PHRASEID
        LANGID = unititem.LANGID
        PHRASE = unititem.PHRASE
        TRANSLATION = unititem.TRANSLATION
        super.init()
    }

    static func getDataByLang(_ langid: Int) -> Observable<[MLangPhrase]> {
        // SQL: SELECT * FROM LANGPHRASES WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)LANGPHRASES?filter=LANGID,eq,\(langid)&order=PHRASE"
        return RestApi.getRecords(url: url)
    }

    static func update(_ id: Int, translation: String) -> Observable<()> {
        // SQL: UPDATE LANGPHRASES SET TRANSLATION=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGPHRASES/\(id)"
        let body = "TRANSLATION=\(translation)"
        return RestApi.update(url: url, body: body).map { print($0) }
    }
    
    static func update(item: MLangPhrase) -> Observable<()> {
        // SQL: UPDATE LANGPHRASES SET PHRASE=?, TRANSLATION=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGPHRASES/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString()!).map { print($0) }
    }

    static func create(item: MLangPhrase) -> Observable<Int> {
        // SQL: INSERT INTO LANGPHRASES (LANGID, PHRASE, TRANSLATION) VALUES (?,?,?)
        let url = "\(CommonApi.urlAPI)LANGPHRASES"
        return RestApi.create(url: url, body: try! item.toJSONString()!).map { Int($0)! }.do(onNext: { print($0) })
    }
    
    static func delete(item: MLangPhrase) -> Observable<()> {
        // SQL: CALL LANGPHRASES_DELETE
        let url = "\(CommonApi.urlSP)LANGPHRASES_DELETE"
        let parameters = item.toParameters()
        return RestApi.callSP(url: url, parameters: parameters).map { print($0) }
    }
}

class MLangPhraseEdit {
    let ID: BehaviorRelay<String>
    let PHRASE: BehaviorRelay<String>
    let TRANSLATION: BehaviorRelay<String>

    init(x: MLangPhrase) {
        ID = BehaviorRelay(value: String(x.ID))
        PHRASE = BehaviorRelay(value: x.PHRASE)
        TRANSLATION = BehaviorRelay(value: x.TRANSLATION)
    }
    
    func save(to x: MLangPhrase) {
        x.PHRASE = PHRASE.value
        x.TRANSLATION = TRANSLATION.value
    }
}
