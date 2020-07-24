//
//  MPattern.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/07.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
class MPattern: NSObject, Codable {
    dynamic var ID = 0
    dynamic var LANGID = 0
    dynamic var PATTERN = ""
    dynamic var NOTE: String?
    dynamic var TAGS: String?

    override init() {
    }
    
    func copy(from x: MPattern) {
        ID = x.ID
        LANGID = x.LANGID
        PATTERN = x.PATTERN
        NOTE = x.NOTE
        TAGS = x.TAGS
    }

    static func getDataByLang(_ langid: Int) -> Observable<[MPattern]> {
        // SQL: SELECT * FROM PATTERNS WHERE LANGID=?
        let url = "\(CommonApi.url)PATTERNS?filter=LANGID,eq,\(langid)&order=PATTERN"
        return RestApi.getRecords(url: url)
    }
    
    static func getDataById(_ id: Int) -> Observable<[MPattern]> {
        // SQL: SELECT * FROM PATTERNS WHERE ID=?
        let url = "\(CommonApi.url)PATTERNS?filter=ID,eq,\(id)"
        return RestApi.getRecords(url: url)
    }
    
    static func update(item: MPattern) -> Observable<()> {
        // SQL: UPDATE PATTERNS SET PATTERN=?, NOTE=?, TAGS=? WHERE ID=?
        let url = "\(CommonApi.url)PATTERNS/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString(prettyPrint: false)!).map { print($0) }
    }

    static func create(item: MPattern) -> Observable<Int> {
        // SQL: INSERT INTO PATTERNS (LANGID, PATTERN, NOTE, TAGS) VALUES (?,?,?,?)
        let url = "\(CommonApi.url)PATTERNS"
        return RestApi.create(url: url, body: try! item.toJSONString(prettyPrint: false)!).map { $0.toInt()! }.do(onNext: { print($0) })
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        // SQL: DELETE PATTERNS WHERE ID=?
        let url = "\(CommonApi.url)PATTERNS/\(id)"
        return RestApi.delete(url: url).map { print($0) }
    }
}
