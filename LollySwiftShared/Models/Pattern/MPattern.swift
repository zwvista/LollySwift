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

    override init() {
    }

    static func getDataByLang(_ langid: Int) -> Observable<[MPattern]> {
        // SQL: SELECT * FROM PATTERNS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)PATTERNS?filter=LANGID,eq,\(langid)&order=PATTERN"
        return RestApi.getRecords(url: url)
    }
    
    static func getDataById(_ id: Int) -> Observable<[MPattern]> {
        // SQL: SELECT * FROM PATTERNS WHERE ID=?
        let url = "\(CommonApi.urlAPI)PATTERNS?filter=ID,eq,\(id)"
        return RestApi.getRecords(url: url)
    }
    
    static func update(item: MPattern) -> Observable<()> {
        // SQL: UPDATE PATTERNS SET PATTERN=?, NOTE=?, TAGS=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)PATTERNS/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString()!).map { print($0) }
    }

    static func create(item: MPattern) -> Observable<Int> {
        // SQL: INSERT INTO PATTERNS (LANGID, PATTERN, NOTE, TAGS) VALUES (?,?,?,?)
        let url = "\(CommonApi.urlAPI)PATTERNS"
        return RestApi.create(url: url, body: try! item.toJSONString()!).map { $0.toInt()! }.do(onNext: { print($0) })
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        // SQL: DELETE PATTERNS WHERE ID=?
        let url = "\(CommonApi.urlAPI)PATTERNS/\(id)"
        return RestApi.delete(url: url).map { print($0) }
    }
}

class MPatternEdit {
    var ID: BehaviorRelay<String>
    var PATTERN: BehaviorRelay<String>
    var NOTE: BehaviorRelay<String>
    var TAGS: BehaviorRelay<String>
    
    init(x: MPattern) {
        ID = BehaviorRelay(value: x.ID.toString)
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

class MPatternVariation: NSObject {
    dynamic var index = 0
    dynamic var variation = ""
}
