//
//  MPatternWebPage.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/01/02.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation

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

class MPatternWebPageEdit: ObservableObject {
    @Published var ID: String
    @Published var PATTERNID: String
    @Published var PATTERN: String
    @Published var SEQNUM: String
    @Published var WEBPAGEID: String
    @Published var TITLE: String
    @Published var URL: String
    
    init() {
        ID = ""
        PATTERNID = ""
        PATTERN = ""
        SEQNUM = ""
        WEBPAGEID = ""
        TITLE = ""
        URL = ""
    }

    init(x: MPatternWebPage) {
        ID = String(x.ID)
        PATTERNID = String(x.PATTERNID)
        PATTERN = x.PATTERN
        SEQNUM = String(x.SEQNUM)
        WEBPAGEID = String(x.WEBPAGEID)
        TITLE = x.TITLE
        URL = x.URL
    }
    
    func save(to x: MPatternWebPage) {
        x.SEQNUM = Int(SEQNUM)!
        x.WEBPAGEID = Int(WEBPAGEID)!
        x.TITLE = TITLE
        x.URL = URL
    }
}
