//
//  MLangBlog.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/15.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

@objcMembers
class MLangBlog: NSObject, Codable {
    dynamic var ID = 0
    dynamic var LANGID = 0
    dynamic var GROUPID = 0
    dynamic var GROUPNAME = ""
    dynamic var TITLE = ""

    static func getDataByLang(_ langid: Int) -> Single<[MLangBlog]> {
        // SQL: SELECT * FROM VLANGBLOGS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)VLANGBLOGS?filter=LANGID,eq,\(langid)"
        return RestApi.getRecords(url: url)
    }

    static func getDataByLangGroup(langid: Int, groupid: Int) -> Single<[MLangBlog]> {
        // SQL: SELECT * FROM VLANGBLOGS WHERE LANGID=? AND GROUPID=?
        let url = "\(CommonApi.urlAPI)VLANGBLOGS?filter=LANGID,eq,\(langid)&filter=GROUPID,eq,\(groupid)"
        return RestApi.getRecords(url: url)
    }

    static func update(item: MLangBlog) -> Single<()> {
        // SQL: UPDATE LANGBLOGS SET GROUPID=?, TITLE=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGS/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString()!).map { print($0) }
    }

    static func create(item: MLangBlog) -> Single<Int> {
        // SQL: INSERT INTO LANGBLOGS (GROUPID, TITLE) VALUES (?,?)
        let url = "\(CommonApi.urlAPI)LANGBLOGS"
        return RestApi.create(url: url, body: try! item.toJSONString()!).map { Int($0)! }.do(onSuccess: { print($0) })
    }
}

@objcMembers
class MLangBlogContent: NSObject, Codable {
    dynamic var ID = 0
    dynamic var TITLE = ""
    dynamic var CONTENT: String? = ""

    static func getDataById(_ id: Int) -> Single<MLangBlogContent?> {
        // SQL: SELECT * FROM LANGBLOGS WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGS?filter=ID,eq,\(id)"
        let o: Single<[MLangBlogContent]> = RestApi.getRecords(url: url)
        return o.map { arr in
            arr.isEmpty ? nil : arr[0]
        }
    }

    static func update(item: MLangBlogContent) -> Single<()> {
        // SQL: UPDATE LANGBLOGS SET CONTENT=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGS/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString()!).map { print($0) }
    }
}

class MLangBlogEdit {
    let ID: String
    let GROUPNAME: String
    let TITLE: BehaviorRelay<String>

    init(x: MLangBlog) {
        ID = "\(x.ID)"
        GROUPNAME = x.GROUPNAME
        TITLE = BehaviorRelay(value: x.TITLE)
    }

    func save(to x: MLangBlog) {
        x.TITLE = TITLE.value
    }
}
