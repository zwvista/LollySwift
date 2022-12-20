//
//  MLangWord.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

@objcMembers
class MLangWords: HasRecords {
    typealias RecordType = MLangWord
    dynamic var records = [MLangWord]()
}

@objcMembers
class MLangWord: NSObject, Codable, MWordProtocol {
    dynamic var ID = 0
    dynamic var LANGID = 0
    dynamic var WORDID: Int { ID }
    dynamic var WORD = ""
    dynamic var NOTE = ""
    dynamic var FAMIID = 0
    dynamic var CORRECT = 0
    dynamic var TOTAL = 0

    var WORDNOTE: String { WORD + (NOTE.isEmpty ? "" : "(\(NOTE))") }
    var ACCURACY: String { TOTAL == 0 ? "N/A" : "\(floor(Double(CORRECT) / Double(TOTAL) * 1000) / 10)%" }

    override init() {
    }

    init(unititem: MUnitWord) {
        ID = unititem.WORDID
        LANGID = unititem.LANGID
        WORD = unititem.WORD
        NOTE = unititem.NOTE
        super.init()
    }

    static func getDataByLang(_ langid: Int) async -> [MLangWord] {
        // SQL: SELECT * FROM LANGWORDS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)VLANGWORDS?filter=LANGID,eq,\(langid)&order=WORD"
        return await RestApi.getRecords(MLangWords.self, url: url)
    }

    static func update(_ id: Int, note: String) async {
        // SQL: UPDATE LANGWORDS SET NOTE=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGWORDS/\(id)"
        let body = "NOTE=\(note)"
        print(await RestApi.update(url: url, body: body))
    }

    static func update(item: MLangWord) async {
        // SQL: UPDATE LANGWORDS SET WORD=?, NOTE=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGWORDS/\(item.ID)"
        print(await RestApi.update(url: url, body: try! item.toJSONString()!))
    }

    static func create(item: MLangWord) async -> Int {
        // SQL: INSERT INTO LANGWORDS (LANGID, WORD) VALUES (?,?)
        let url = "\(CommonApi.urlAPI)LANGWORDS"
        let id = Int(await RestApi.create(url: url, body: try! item.toJSONString()!))!
        print(id)
        return id
    }

    static func delete(item: MLangWord) async {
        // SQL: CALL LANGWORDS_DELETE
        let url = "\(CommonApi.urlSP)LANGWORDS_DELETE"
        let parameters = item.toParameters()
        print(await RestApi.callSP(url: url, parameters: parameters))
    }
}

class MLangWordEdit: ObservableObject {
    @Published var ID: String
    @Published var WORD: String
    @Published var NOTE: String
    @Published var FAMIID: String
    @Published var ACCURACY: String

    init(x: MLangWord) {
        ID = String(x.ID)
        WORD = x.WORD
        NOTE = x.NOTE
        FAMIID = String(x.FAMIID)
        ACCURACY = x.ACCURACY
    }

    func save(to x: MLangWord) {
        x.WORD = WORD
        x.NOTE = NOTE
    }
}
