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
class MPatternWebPages: HasRecords {
    typealias RecordType = MPatternWebPage
    dynamic var records = [MPatternWebPage]()
}

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

    static func getDataByPattern(_ patternid: Int) async -> [MPatternWebPage] {
        // SQL: SELECT * FROM VPATTERNSWEBPAGES WHERE PATTERNID=?
        let url = "\(CommonApi.urlAPI)VPATTERNSWEBPAGES?filter=PATTERNID,eq,\(patternid)&order=SEQNUM"
        return await RestApi.getRecords(MPatternWebPages.self, url: url)
    }
    
    static func getDataById(_ id: Int) async -> [MPatternWebPage] {
        // SQL: SELECT * FROM VPATTERNSWEBPAGES WHERE ID=?
        let url = "\(CommonApi.urlAPI)VPATTERNSWEBPAGES?filter=ID,eq,\(id)"
        return await RestApi.getRecords(MPatternWebPages.self, url: url)
    }
    
    static func update(_ id: Int, seqnum: Int) async {
        // SQL: UPDATE PATTERNSWEBPAGES SET SEQNUM=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)PATTERNSWEBPAGES/\(id)"
        let body = "SEQNUM=\(seqnum)"
        print(await RestApi.update(url: url, body: body))
    }

    static func update(item: MPatternWebPage) async {
        // SQL: UPDATE PATTERNSWEBPAGES SET WEBPAGE=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)PATTERNSWEBPAGES/\(item.ID)"
        print(await RestApi.update(url: url, body: try! item.toJSONString()!))
    }

    static func create(item: MPatternWebPage) async -> Int {
        // SQL: INSERT INTO PATTERNSWEBPAGES (PATTERNID, SEQNUM, WEBPAGE) VALUES (?,?,?)
        let url = "\(CommonApi.urlAPI)PATTERNSWEBPAGES"
        let id = Int(await RestApi.create(url: url, body: try! item.toJSONString()!))!
        print(id)
        return id
    }
    
    static func delete(_ id: Int) async {
        // SQL: DELETE PATTERNSWEBPAGES WHERE ID=?
        let url = "\(CommonApi.urlAPI)PATTERNSWEBPAGES/\(id)"
        print(await RestApi.delete(url: url))
    }
}

class MPatternWebPageEdit {
    let ID: BehaviorRelay<String>
    let PATTERNID: BehaviorRelay<String>
    let PATTERN: BehaviorRelay<String>
    let SEQNUM: BehaviorRelay<String>
    let WEBPAGEID: BehaviorRelay<String>
    let TITLE: BehaviorRelay<String>
    let URL: BehaviorRelay<String>
    
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
        ID = BehaviorRelay(value: String(x.ID))
        PATTERNID = BehaviorRelay(value: String(x.PATTERNID))
        PATTERN = BehaviorRelay(value: x.PATTERN)
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
