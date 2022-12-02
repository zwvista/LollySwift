//
//  MWebPage.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/01/02.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation

@objcMembers
class MWebPages: HasRecords {
    typealias RecordType = MWebPage
    dynamic var records = [MWebPage]()
}

@objcMembers
class MWebPage: NSObject, Codable {
    var ID = 0
    var TITLE = ""
    var URL = ""

    override init() {
    }

    init(x: MPatternWebPage) {
        ID = x.WEBPAGEID
        TITLE = x.TITLE
        URL = x.URL
    }

    static func getDataById(_ id: Int) async -> [MWebPage] {
        // SQL: SELECT * FROM WEBPAGES WHERE ID=?
        let url = "\(CommonApi.urlAPI)WEBPAGES?filter=ID,eq,\(id)"
        return await RestApi.getRecords(MWebPages.self, url: url)
    }
    
    static func getDataBySearch(title t: String, url u: String) async -> [MWebPage] {
        // SQL: SELECT * FROM WEBPAGES WHERE LOCATE(?, TITLE) <> 0 AND LOCATE(?, URL) <> 0
        var filter = ""
        if !t.isEmpty {
            filter = "?filter=TITLE,cs,\(t.urlEncoded())"
        }
        if !u.isEmpty {
            filter += filter.isEmpty ? "?" : "&"
            filter += "filter=URL,cs,\(u.urlEncoded())"
        }
        let url = "\(CommonApi.urlAPI)WEBPAGES\(filter)"
        return await RestApi.getRecords(MWebPages.self, url: url)
    }

    static func updatePattern(item: MPatternWebPage) async {
        // SQL: UPDATE WEBPAGES SET TITLE=?, URL=? WHERE ID=?
        let item2 = MWebPage(x: item)
        let url = "\(CommonApi.urlAPI)WEBPAGES/\(item.ID)"
        print(await RestApi.update(url: url, body: try! item2.toJSONString()!))
    }

    static func createPattern(item: MPatternWebPage) async -> Int {
        // SQL: INSERT INTO WEBPAGES (TITLE, URL) VALUES (?,?)
        let item2 = MWebPage(x: item)
        let url = "\(CommonApi.urlAPI)WEBPAGES"
        let id = Int(await RestApi.create(url: url, body: try! item2.toJSONString()!))!
        print(id)
        return id
    }

    static func update(item: MWebPage) async {
        // SQL: UPDATE WEBPAGES SET TITLE=?, URL=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)WEBPAGES/\(item.ID)"
        print(await RestApi.update(url: url, body: try! item.toJSONString()!))
    }

    static func create(item: MWebPage) async -> Int {
        // SQL: INSERT INTO WEBPAGES (TITLE, URL) VALUES (?,?)
        let url = "\(CommonApi.urlAPI)WEBPAGES"
        let id = Int(await RestApi.create(url: url, body: try! item.toJSONString()!))!
        print(id)
        return id
    }
    
    static func delete(_ id: Int) async {
        // SQL: DELETE WEBPAGES WHERE ID=?
        let url = "\(CommonApi.urlAPI)WEBPAGES/\(id)"
        print(await RestApi.delete(url: url))
    }
}
