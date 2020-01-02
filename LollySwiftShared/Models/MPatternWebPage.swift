//
//  MPatternWebPage.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/01/02.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
class MPatternWebPage: NSObject, Codable {
    var ID = 0
    var PATTERNID = 0
    var PATTERN = ""
    var WEBPAGE = ""
    
    override init() {
    }
    
    func copy(from x: MPatternWebPage) {
        ID = x.ID
        PATTERNID = x.PATTERNID
        PATTERN = x.PATTERN
        WEBPAGE = x.WEBPAGE
    }

    static func getDataByPattern(_ patternid: Int) -> Observable<[MPatternWebPage]> {
        // SQL: SELECT * FROM PATTERNSWEBPAGES WHERE PATTERNID=?
        let url = "\(CommonApi.url)VPATTERNSWEBPAGES?filter=PATTERNID,eq,\(patternid)"
        return RestApi.getRecords(url: url)
    }
    
    static func getDataById(_ id: Int) -> Observable<[MPatternWebPage]> {
        // SQL: SELECT * FROM PATTERNSWEBPAGES WHERE ID=?
        let url = "\(CommonApi.url)VPATTERNSWEBPAGES?filter=ID,eq,\(id)"
        return RestApi.getRecords(url: url)
    }
    
    static func update(item: MPatternWebPage) -> Observable<()> {
        // SQL: UPDATE PATTERNSWEBPAGES SET PATTERNID=?, WEBPAGE=? WHERE ID=?
        let url = "\(CommonApi.url)PATTERNSWEBPAGES/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString(prettyPrint: false)!).map { print($0) }
    }

    static func create(item: MPatternWebPage) -> Observable<Int> {
        // SQL: INSERT INTO PATTERNSWEBPAGES (LANGID, PATTERNID, WEBPAGE) VALUES (?,?,?)
        let url = "\(CommonApi.url)PATTERNSWEBPAGES"
        return RestApi.create(url: url, body: try! item.toJSONString(prettyPrint: false)!).map { $0.toInt()! }.do(onNext: { print($0) })
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        // SQL: DELETE PATTERNSWEBPAGES WHERE ID=?
        let url = "\(CommonApi.url)PATTERNSWEBPAGES/\(id)"
        return RestApi.delete(url: url).map { print($0) }
    }
}
