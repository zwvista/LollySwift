//
//  MPattern.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/07.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

@objcMembers
class MPattern: NSObject, Codable {
    dynamic var ID = 0
    dynamic var LANGID = 0
    dynamic var PATTERN = ""
    dynamic var NOTE = ""
    dynamic var TAGS = ""
    dynamic var IDS_MERGE: String?
    dynamic var PATTERNS_SPLIT: String?

    override init() {
    }

    static func getDataByLang(_ langid: Int) -> Single<[MPattern]> {
        // SQL: SELECT * FROM PATTERNS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)PATTERNS?filter=LANGID,eq,\(langid)&order=PATTERN"
        return RestApi.getRecords(url: url)
    }

    static func getDataById(_ id: Int) -> Single<[MPattern]> {
        // SQL: SELECT * FROM PATTERNS WHERE ID=?
        let url = "\(CommonApi.urlAPI)PATTERNS?filter=ID,eq,\(id)"
        return RestApi.getRecords(url: url)
    }

    static func update(item: MPattern) -> Single<()> {
        // SQL: UPDATE PATTERNS SET PATTERN=?, NOTE=?, TAGS=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)PATTERNS/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString()!).map { print($0) }
    }

    static func create(item: MPattern) -> Single<Int> {
        // SQL: INSERT INTO PATTERNS (LANGID, PATTERN, NOTE, TAGS) VALUES (?,?,?,?)
        let url = "\(CommonApi.urlAPI)PATTERNS"
        return RestApi.create(url: url, body: try! item.toJSONString()!).map { Int($0)! }.do(onSuccess: { print($0) })
    }

    static func delete(_ id: Int) -> Single<()> {
        // SQL: DELETE PATTERNS WHERE ID=?
        let url = "\(CommonApi.urlAPI)PATTERNS/\(id)"
        return RestApi.delete(url: url).map { print($0) }
    }

    static func mergePatterns(item: MPattern) -> Single<()> {
        // SQL: PATTERNS_MERGE
        let url = "\(CommonApi.urlSP)PATTERNS_MERGE"
        let parameters = item.toParameters()
        return RestApi.callSP(url: url, parameters: parameters).map { print($0) }
    }

    static func splitPattern(item: MPattern) -> Single<()> {
        // SQL: PATTERNS_SPLIT
        let url = "\(CommonApi.urlSP)PATTERNS_SPLIT"
        let parameters = item.toParameters()
        return RestApi.callSP(url: url, parameters: parameters).map { print($0) }
    }
}

class MPatternEdit {
    let ID: String
    let PATTERN: BehaviorRelay<String>
    let NOTE: BehaviorRelay<String>
    let TAGS: BehaviorRelay<String>

    init() {
        ID = ""
        PATTERN = BehaviorRelay(value: "")
        NOTE = BehaviorRelay(value: "")
        TAGS = BehaviorRelay(value: "")
    }

    init(x: MPattern) {
        ID = "\(x.ID)"
        PATTERN = BehaviorRelay(value: x.PATTERN)
        NOTE = BehaviorRelay(value: x.NOTE)
        TAGS = BehaviorRelay(value: x.TAGS)
    }

    func save(to x: MPattern) {
        x.PATTERN = PATTERN.value
        x.NOTE = NOTE.value
        x.TAGS = TAGS.value
    }
}

@objcMembers
class MPatternVariation: NSObject {
    dynamic var index = 0
    dynamic var variation = ""
}
