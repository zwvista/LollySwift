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

    static func getDataByLang(_ langid: Int) -> Single<[MLangPhrase]> {
        // SQL: SELECT * FROM LANGPHRASES WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)LANGPHRASES?filter=LANGID,eq,\(langid)&order=PHRASE"
        return RestApi.getRecords(url: url)
    }

    static func update(_ id: Int, translation: String) -> Single<()> {
        // SQL: UPDATE LANGPHRASES SET TRANSLATION=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGPHRASES/\(id)"
        let body = ["TRANSLATION": translation]
        return RestApi.update(url: url, body: body).map { print($0) }
    }

    static func update(item: MLangPhrase) -> Single<()> {
        // SQL: UPDATE LANGPHRASES SET PHRASE=?, TRANSLATION=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGPHRASES/\(item.ID)"
        return RestApi.update(url: url, body: item.toParameters(isSP: false)).map { print($0) }
    }

    static func create(item: MLangPhrase) -> Single<Int> {
        // SQL: INSERT INTO LANGPHRASES (LANGID, PHRASE, TRANSLATION) VALUES (?,?,?)
        let url = "\(CommonApi.urlAPI)LANGPHRASES"
        return RestApi.create(url: url, body: item.toParameters(isSP: false)).map { Int($0)! }.do(onSuccess: { print($0) })
    }

    static func delete(item: MLangPhrase) -> Single<()> {
        // SQL: CALL LANGPHRASES_DELETE
        let url = "\(CommonApi.urlSP)LANGPHRASES_DELETE"
        let parameters = item.toParameters(isSP: true)
        return RestApi.callSP(url: url, parameters: parameters).map { print($0) }
    }
}

class MLangPhraseEdit {
    let ID: String
    let PHRASE: BehaviorRelay<String>
    let TRANSLATION: BehaviorRelay<String>

    init(x: MLangPhrase) {
        ID = "\(x.ID)"
        PHRASE = BehaviorRelay(value: x.PHRASE)
        TRANSLATION = BehaviorRelay(value: x.TRANSLATION)
    }

    func save(to x: MLangPhrase) {
        x.PHRASE = PHRASE.value
        x.TRANSLATION = TRANSLATION.value
    }
}
