//
//  MWebPage.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/01/02.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift

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

    static func getDataById(_ id: Int) -> Single<[MWebPage]> {
        // SQL: SELECT * FROM WEBPAGES WHERE ID=?
        let url = "\(CommonApi.urlAPI)WEBPAGES?filter=ID,eq,\(id)"
        return RestApi.getRecords(url: url)
    }
    
    static func getDataBySearch(title t: String, url u: String) -> Single<[MWebPage]> {
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
        return RestApi.getRecords(url: url)
    }

    static func update(item: MPatternWebPage) -> Single<()> {
        // SQL: UPDATE WEBPAGES SET TITLE=?, URL=? WHERE ID=?
        let item2 = MWebPage(x: item)
        let url = "\(CommonApi.urlAPI)WEBPAGES/\(item.ID)"
        return RestApi.update(url: url, body: try! item2.toJSONString()!).map { print($0) }
    }

    static func create(item: MPatternWebPage) -> Single<Int> {
        // SQL: INSERT INTO WEBPAGES (TITLE, URL) VALUES (?,?)
        let item2 = MWebPage(x: item)
        let url = "\(CommonApi.urlAPI)WEBPAGES"
        return RestApi.create(url: url, body: try! item2.toJSONString()!).map { Int($0)! }.do(onSuccess: { print($0) })
    }

    static func update(item: MWebPage) -> Single<()> {
        // SQL: UPDATE WEBPAGES SET TITLE=?, URL=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)WEBPAGES/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString()!).map { print($0) }
    }

    static func create(item: MWebPage) -> Single<Int> {
        // SQL: INSERT INTO WEBPAGES (TITLE, URL) VALUES (?,?)
        let url = "\(CommonApi.urlAPI)WEBPAGES"
        return RestApi.create(url: url, body: try! item.toJSONString()!).map { Int($0)! }.do(onSuccess: { print($0) })
    }
    
    static func delete(_ id: Int) -> Single<()> {
        // SQL: DELETE WEBPAGES WHERE ID=?
        let url = "\(CommonApi.urlAPI)WEBPAGES/\(id)"
        return RestApi.delete(url: url).map { print($0) }
    }
}
