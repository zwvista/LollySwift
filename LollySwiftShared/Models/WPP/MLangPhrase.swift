//
//  MLangPhrase.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/07.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

@objcMembers
class MLangPhrases: HasRecords, @unchecked Sendable {
    typealias RecordType = MLangPhrase
    dynamic var records = [MLangPhrase]()
}

@objcMembers
class MLangPhrase: NSObject, Codable, MPhraseProtocol, @unchecked Sendable {
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

    static func getDataByLang(_ langid: Int) async -> [MLangPhrase] {
        // SQL: SELECT * FROM LANGPHRASES WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)LANGPHRASES?filter=LANGID,eq,\(langid)&order=PHRASE"
        return await RestApi.getRecords(MLangPhrases.self, url: url)
    }

    static func update(_ id: Int, translation: String) async {
        // SQL: UPDATE LANGPHRASES SET TRANSLATION=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGPHRASES/\(id)"
        let body = ["TRANSLATION": translation]
        print(await RestApi.update(url: url, body: body))
    }

    static func update(item: MLangPhrase) async {
        // SQL: UPDATE LANGPHRASES SET PHRASE=?, TRANSLATION=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGPHRASES/\(item.ID)"
        print(await RestApi.update(url: url, body: item.toParameters(isSP: false)))
    }

    static func create(item: MLangPhrase) async -> Int {
        // SQL: INSERT INTO LANGPHRASES (LANGID, PHRASE, TRANSLATION) VALUES (?,?,?)
        let url = "\(CommonApi.urlAPI)LANGPHRASES"
        let id = Int(await RestApi.create(url: url, body: item.toParameters(isSP: false)))!
        print(id)
        return id
    }

    static func delete(item: MLangPhrase) async {
        // SQL: CALL LANGPHRASES_DELETE
        let url = "\(CommonApi.urlSP)LANGPHRASES_DELETE"
        let parameters = item.toParameters(isSP: true)
        print(await RestApi.callSP(url: url, parameters: parameters))
    }
}

class MLangPhraseEdit: ObservableObject {
    let ID: String
    @Published var PHRASE: String
    @Published var TRANSLATION: String

    init(x: MLangPhrase) {
        ID = "\(x.ID)"
        PHRASE = x.PHRASE
        TRANSLATION = x.TRANSLATION
    }

    func save(to x: MLangPhrase) {
        x.PHRASE = PHRASE
        x.TRANSLATION = TRANSLATION
    }
}
