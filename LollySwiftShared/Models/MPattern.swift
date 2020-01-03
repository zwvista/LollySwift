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
    var ID = 0
    var LANGID = 0
    var PATTERN = ""
    var PATTERNTYPEID = 0
    var NOTE: String?
    
    override init() {
    }
    
    func copy(from x: MPattern) {
        ID = x.ID
        LANGID = x.LANGID
        PATTERN = x.PATTERN
        PATTERNTYPEID = x.PATTERNTYPEID
        NOTE = x.NOTE
    }

    static func getSentenceDataByLang(_ langid: Int) -> Observable<[MPattern]> {
        // SQL: SELECT * FROM VPATTERNS WHERE LANGID=? AND PATTERNTYPEID = 2
        let url = "\(CommonApi.url)VPATTERNS?filter=LANGID,eq,\(langid)&filter=PATTERNTYPEID,eq,2&order=PATTERN"
        return RestApi.getRecords(url: url)
    }
    
    static func getDataById(_ id: Int) -> Observable<[MPattern]> {
        // SQL: SELECT * FROM PATTERNS WHERE ID=?
        let url = "\(CommonApi.url)PATTERNS?filter=ID,eq,\(id)"
        return RestApi.getRecords(url: url)
    }

    static func update(_ id: Int, note: String) -> Observable<()> {
        // SQL: UPDATE PATTERNS SET NOTE=? WHERE ID=?
        let url = "\(CommonApi.url)PATTERNS/\(id)"
        let body = "NOTE=\(note)"
        return RestApi.update(url: url, body: body).map { print($0) }
    }
    
    static func update(item: MPattern) -> Observable<()> {
        // SQL: UPDATE PATTERNS SET PATTERN=?, NOTE=? WHERE ID=?
        let url = "\(CommonApi.url)PATTERNS/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString(prettyPrint: false)!).map { print($0) }
    }

    static func create(item: MPattern) -> Observable<Int> {
        // SQL: INSERT INTO PATTERNS (LANGID, PATTERN, NOTE) VALUES (?,?,?)
        let url = "\(CommonApi.url)PATTERNS"
        return RestApi.create(url: url, body: try! item.toJSONString(prettyPrint: false)!).map { $0.toInt()! }.do(onNext: { print($0) })
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        // SQL: DELETE PATTERNS WHERE ID=?
        let url = "\(CommonApi.url)PATTERNS/\(id)"
        return RestApi.delete(url: url).map { print($0) }
    }
}
