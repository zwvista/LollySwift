//
//  MPattern.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/07.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

@objcMembers
class MPatterns: HasRecords {
    typealias RecordType = MPattern
    dynamic var records = [MPattern]()
}

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

    static func getDataByLang(_ langid: Int) async -> [MPattern] {
        // SQL: SELECT * FROM PATTERNS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)PATTERNS?filter=LANGID,eq,\(langid)&order=PATTERN"
        return await RestApi.getRecords(MPatterns.self, url: url)
    }
    
    static func getDataById(_ id: Int) async -> [MPattern] {
        // SQL: SELECT * FROM PATTERNS WHERE ID=?
        let url = "\(CommonApi.urlAPI)PATTERNS?filter=ID,eq,\(id)"
        return await RestApi.getRecords(MPatterns.self, url: url)
    }
    
    static func update(item: MPattern) async {
        // SQL: UPDATE PATTERNS SET PATTERN=?, NOTE=?, TAGS=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)PATTERNS/\(item.ID)"
        print(await RestApi.update(url: url, body: try! item.toJSONString()!))
    }

    static func create(item: MPattern) async -> Int {
        // SQL: INSERT INTO PATTERNS (LANGID, PATTERN, NOTE, TAGS) VALUES (?,?,?,?)
        let url = "\(CommonApi.urlAPI)PATTERNS"
        let id = Int(await RestApi.create(url: url, body: try! item.toJSONString()!))!
        print(id)
        return id
    }
    
    static func delete(_ id: Int) async {
        // SQL: DELETE PATTERNS WHERE ID=?
        let url = "\(CommonApi.urlAPI)PATTERNS/\(id)"
        print(await RestApi.delete(url: url))
    }
    
    static func mergePatterns(item: MPattern) async {
        // SQL: PATTERNS_MERGE
        let url = "\(CommonApi.urlSP)PATTERNS_MERGE"
        let parameters = item.toParameters()
        print(await RestApi.callSP(url: url, parameters: parameters))
    }
    
    static func splitPattern(item: MPattern) async {
        // SQL: PATTERNS_SPLIT
        let url = "\(CommonApi.urlSP)PATTERNS_SPLIT"
        let parameters = item.toParameters()
        print(await RestApi.callSP(url: url, parameters: parameters))
    }
}

class MPatternEdit {
    let ID: BehaviorRelay<String>
    let PATTERN: BehaviorRelay<String>
    let NOTE: BehaviorRelay<String>
    let TAGS: BehaviorRelay<String>
    
    init() {
        ID = BehaviorRelay(value: "")
        PATTERN = BehaviorRelay(value: "")
        NOTE = BehaviorRelay(value: "")
        TAGS = BehaviorRelay(value: "")
    }

    init(x: MPattern) {
        ID = BehaviorRelay(value: String(x.ID))
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
