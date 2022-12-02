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

class MPatternEdit: ObservableObject {
    @Published let ID: String
    @Published let PATTERN: String
    @Published let NOTE: String
    @Published let TAGS: String
    
    init() {
        ID = ""
        PATTERN = ""
        NOTE = ""
        TAGS = ""
    }

    init(x: MPattern) {
        ID = String(x.ID)
        PATTERN = x.PATTERN
        NOTE = x.NOTE
        TAGS = x.TAGS
    }
    
    func save(to x: MPattern) {
        x.PATTERN = PATTERN
        x.NOTE = NOTE
        x.TAGS = TAGS
    }
}

@objcMembers
class MPatternVariation: NSObject {
    dynamic var index = 0
    dynamic var variation = ""
}
