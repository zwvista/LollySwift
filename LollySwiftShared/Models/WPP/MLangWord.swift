//
//  MLangWord.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

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
    var ACCURACY: String { TOTAL == 0 ? "N/A" : "\(floor(CORRECT.toDouble / TOTAL.toDouble * 1000) / 10)%" }

    override init() {
    }
    
    init(unititem: MUnitWord) {
        ID = unititem.WORDID
        LANGID = unititem.LANGID
        WORD = unititem.WORD
        NOTE = unititem.NOTE
        super.init()
    }

    static func getDataByLang(_ langid: Int) -> Observable<[MLangWord]> {
        // SQL: SELECT * FROM LANGWORDS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)VLANGWORDS?filter=LANGID,eq,\(langid)&order=WORD"
        return RestApi.getRecords(url: url)
    }
    
    static func update(_ id: Int, note: String) -> Observable<()> {
        // SQL: UPDATE LANGWORDS SET NOTE=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGWORDS/\(id)"
        let body = "NOTE=\(note)"
        return RestApi.update(url: url, body: body).map { print($0) }
    }

    static func update(item: MLangWord) -> Observable<()> {
        // SQL: UPDATE LANGWORDS SET WORD=?, NOTE=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGWORDS/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString(prettyPrint: false)!).map { print($0) }
    }

    static func create(item: MLangWord) -> Observable<Int> {
        // SQL: INSERT INTO LANGWORDS (LANGID, WORD) VALUES (?,?)
        let url = "\(CommonApi.urlAPI)LANGWORDS"
        return RestApi.create(url: url, body: try! item.toJSONString()!).map { $0.toInt()! }.do(onNext: { print($0) })
    }
    
    static func delete(item: MLangWord) -> Observable<()> {
        // SQL: CALL LANGWORDS_DELETE
        let url = "\(CommonApi.urlSP)LANGWORDS_DELETE"
        let parameters = try! item.toParameters()
        return RestApi.callSP(url: url, parameters: parameters).map { print($0) }
    }
}

class MLangWordEdit {
    let ID: BehaviorRelay<String>
    let WORD: BehaviorRelay<String>
    let NOTE: BehaviorRelay<String>
    let FAMIID: BehaviorRelay<String>
    let ACCURACY: BehaviorRelay<String>

    init(x: MLangWord) {
        ID = BehaviorRelay(value: x.ID.toString)
        WORD = BehaviorRelay(value: x.WORD)
        NOTE = BehaviorRelay(value: x.NOTE)
        FAMIID = BehaviorRelay(value: x.FAMIID.toString)
        ACCURACY = BehaviorRelay(value: x.ACCURACY)
    }
    
    func save(to x: MLangWord) {
        x.WORD = WORD.value
        x.NOTE = NOTE.value
    }
}
