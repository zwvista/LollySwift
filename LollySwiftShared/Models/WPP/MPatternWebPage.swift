//
//  MPatternWebPage.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/01/02.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

@objcMembers
class MPatternWebPage: NSObject, Codable {
    dynamic var ID = 0
    dynamic var PATTERNID = 0
    dynamic var PATTERN = ""
    dynamic var SEQNUM = 0
    dynamic var WEBPAGEID = 0
    dynamic var TITLE = ""
    dynamic var URL = ""

    override init() {
    }
    
    func copy(from x: MPatternWebPage) {
        ID = x.ID
        PATTERNID = x.PATTERNID
        PATTERN = x.PATTERN
        SEQNUM = x.SEQNUM
        WEBPAGEID = x.WEBPAGEID
        TITLE = x.TITLE
        URL = x.URL
    }

    static func getDataByPattern(_ patternid: Int) -> Observable<[MPatternWebPage]> {
        // SQL: SELECT * FROM VPATTERNSWEBPAGES WHERE PATTERNID=?
        let url = "\(CommonApi.urlAPI)VPATTERNSWEBPAGES?filter=PATTERNID,eq,\(patternid)&order=SEQNUM"
        return RestApi.getRecords(url: url)
    }
    
    static func getDataById(_ id: Int) -> Observable<[MPatternWebPage]> {
        // SQL: SELECT * FROM VPATTERNSWEBPAGES WHERE ID=?
        let url = "\(CommonApi.urlAPI)VPATTERNSWEBPAGES?filter=ID,eq,\(id)"
        return RestApi.getRecords(url: url)
    }
    
    static func update(_ id: Int, seqnum: Int) -> Observable<()> {
        // SQL: UPDATE PATTERNSWEBPAGES SET SEQNUM=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)PATTERNSWEBPAGES/\(id)"
        let body = "SEQNUM=\(seqnum)"
        return RestApi.update(url: url, body: body).map { print($0) }
    }

    static func update(item: MPatternWebPage) -> Observable<()> {
        // SQL: UPDATE PATTERNSWEBPAGES SET WEBPAGE=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)PATTERNSWEBPAGES/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString()!).map { print($0) }
    }

    static func create(item: MPatternWebPage) -> Observable<Int> {
        // SQL: INSERT INTO PATTERNSWEBPAGES (PATTERNID, SEQNUM, WEBPAGE) VALUES (?,?,?)
        let url = "\(CommonApi.urlAPI)PATTERNSWEBPAGES"
        return RestApi.create(url: url, body: try! item.toJSONString()!).map { $0.toInt()! }.do(onNext: { print($0) })
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        // SQL: DELETE PATTERNSWEBPAGES WHERE ID=?
        let url = "\(CommonApi.urlAPI)PATTERNSWEBPAGES/\(id)"
        return RestApi.delete(url: url).map { print($0) }
    }
}

class MPatternWebPageEdit {
    var ID: BehaviorRelay<String>
    var PATTERNID: BehaviorRelay<String>
    var PATTERN: BehaviorRelay<String>
    var SEQNUM: BehaviorRelay<String>
    var WEBPAGEID: BehaviorRelay<String>
    var TITLE: BehaviorRelay<String>
    var URL: BehaviorRelay<String>
    
    init() {
        ID = BehaviorRelay(value: "")
        PATTERNID = BehaviorRelay(value: "")
        PATTERN = BehaviorRelay(value: "")
        SEQNUM = BehaviorRelay(value: "")
        WEBPAGEID = BehaviorRelay(value: "")
        TITLE = BehaviorRelay(value: "")
        URL = BehaviorRelay(value: "")
    }

    init(x: MPatternWebPage) {
        ID = BehaviorRelay(value: x.ID.toString)
        PATTERNID = BehaviorRelay(value: x.PATTERNID.toString)
        PATTERN = BehaviorRelay(value: x.PATTERN)
        SEQNUM = BehaviorRelay(value: x.SEQNUM.toString)
        WEBPAGEID = BehaviorRelay(value: x.WEBPAGEID.toString)
        TITLE = BehaviorRelay(value: x.TITLE)
        URL = BehaviorRelay(value: x.URL)
    }
    
    func save(to x: MPatternWebPage) {
        x.SEQNUM = SEQNUM.value.toInt()!
        x.WEBPAGEID = WEBPAGEID.value.toInt()!
        x.TITLE = TITLE.value
        x.URL = URL.value
    }
}
