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

    static func getDataByPattern(_ patternid: Int) -> Single<[MPatternWebPage]> {
        // SQL: SELECT * FROM VPATTERNSWEBPAGES WHERE PATTERNID=?
        let url = "\(CommonApi.urlAPI)VPATTERNSWEBPAGES?filter=PATTERNID,eq,\(patternid)&order=SEQNUM"
        return RestApi.getRecords(url: url)
    }

    static func getDataById(_ id: Int) -> Single<[MPatternWebPage]> {
        // SQL: SELECT * FROM VPATTERNSWEBPAGES WHERE ID=?
        let url = "\(CommonApi.urlAPI)VPATTERNSWEBPAGES?filter=ID,eq,\(id)"
        return RestApi.getRecords(url: url)
    }

    static func update(_ id: Int, seqnum: Int) -> Single<()> {
        // SQL: UPDATE PATTERNSWEBPAGES SET SEQNUM=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)PATTERNSWEBPAGES/\(id)"
        let body = "SEQNUM=\(seqnum)"
        return RestApi.update(url: url, body: body).map { print($0) }
    }

    static func update(item: MPatternWebPage) -> Single<()> {
        // SQL: UPDATE PATTERNSWEBPAGES SET WEBPAGE=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)PATTERNSWEBPAGES/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString()!).map { print($0) }
    }

    static func create(item: MPatternWebPage) -> Single<Int> {
        // SQL: INSERT INTO PATTERNSWEBPAGES (PATTERNID, SEQNUM, WEBPAGE) VALUES (?,?,?)
        let url = "\(CommonApi.urlAPI)PATTERNSWEBPAGES"
        return RestApi.create(url: url, body: try! item.toJSONString()!).map { Int($0)! }.do(onSuccess: { print($0) })
    }

    static func delete(_ id: Int) -> Single<()> {
        // SQL: DELETE PATTERNSWEBPAGES WHERE ID=?
        let url = "\(CommonApi.urlAPI)PATTERNSWEBPAGES/\(id)"
        return RestApi.delete(url: url).map { print($0) }
    }
}

class MPatternWebPageEdit {
    let ID: String
    let PATTERNID: String
    let PATTERN: String
    let SEQNUM: BehaviorRelay<String>
    let WEBPAGEID: BehaviorRelay<String>
    let TITLE: BehaviorRelay<String>
    let URL: BehaviorRelay<String>

    init() {
        ID = ""
        PATTERNID = ""
        PATTERN = ""
        SEQNUM = BehaviorRelay(value: "")
        WEBPAGEID = BehaviorRelay(value: "")
        TITLE = BehaviorRelay(value: "")
        URL = BehaviorRelay(value: "")
    }

    init(x: MPatternWebPage) {
        ID = "\(x.ID)"
        PATTERNID = "\(x.PATTERNID)"
        PATTERN = x.PATTERN
        SEQNUM = BehaviorRelay(value: String(x.SEQNUM))
        WEBPAGEID = BehaviorRelay(value: String(x.WEBPAGEID))
        TITLE = BehaviorRelay(value: x.TITLE)
        URL = BehaviorRelay(value: x.URL)
    }

    func save(to x: MPatternWebPage) {
        x.SEQNUM = Int(SEQNUM.value)!
        x.WEBPAGEID = Int(WEBPAGEID.value)!
        x.TITLE = TITLE.value
        x.URL = URL.value
    }
}
