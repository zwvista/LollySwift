//
//  MLangPattern.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/07.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
class MLangPattern: NSObject, Codable {
    var ID = 0
    var LANGID = 0
    var PATTERN = ""
    var NOTE: String?
    
    override init() {
    }
    
    func copy(from x: MLangPattern) {
        ID = x.ID
        LANGID = x.LANGID
        PATTERN = x.PATTERN
        NOTE = x.NOTE
    }

    static func getDataByLang(_ langid: Int) -> Observable<[MLangPattern]> {
        // SQL: SELECT * FROM LANGPATTERNS WHERE LANGID=?
        let url = "\(CommonApi.url)LANGPATTERNS?filter=LANGID,eq,\(langid)&order=PATTERN"
        return RestApi.getRecords(url: url)
    }
    
    static func getDataById(_ id: Int) -> Observable<[MLangPattern]> {
        // SQL: SELECT * FROM LANGPATTERNS WHERE ID=?
        let url = "\(CommonApi.url)LANGPATTERNS?filter=ID,eq,\(id)"
        return RestApi.getRecords(url: url)
    }

    static func update(_ id: Int, note: String) -> Observable<()> {
        // SQL: UPDATE LANGPATTERNS SET NOTE=? WHERE ID=?
        let url = "\(CommonApi.url)LANGPATTERNS/\(id)"
        let body = "NOTE=\(note)"
        return RestApi.update(url: url, body: body).map { print($0) }
    }
    
    static func update(item: MLangPattern) -> Observable<()> {
        // SQL: UPDATE LANGPATTERNS SET PATTERN=?, NOTE=? WHERE ID=?
        let url = "\(CommonApi.url)LANGPATTERNS/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString(prettyPrint: false)!).map { print($0) }
    }

    static func create(item: MLangPattern) -> Observable<Int> {
        // SQL: INSERT INTO LANGPATTERNS (LANGID, PATTERN, NOTE) VALUES (?,?,?)
        let url = "\(CommonApi.url)LANGPATTERNS"
        return RestApi.create(url: url, body: try! item.toJSONString(prettyPrint: false)!).map { $0.toInt()! }.do(onNext: { print($0) })
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        // SQL: DELETE LANGPATTERNS WHERE ID=?
        let url = "\(CommonApi.url)LANGPATTERNS/\(id)"
        return RestApi.delete(url: url).map { print($0) }
    }
}
