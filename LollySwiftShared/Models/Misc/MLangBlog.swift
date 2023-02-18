//
//  MLangBlog.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/15.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
class MLangBlog: NSObject, Codable {
    dynamic var ID = 0
    dynamic var LANGID = 0
    dynamic var BLOGGROUPID = 0
    dynamic var BLOGGROUPNAME = ""
    dynamic var TITLE = ""
    dynamic var CONTENT = ""

    static func getDataByLang(_ langid: Int) -> Single<[MLangBlog]> {
        // SQL: SELECT * FROM VLANGBLOGS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)VLANGBLOGS?filter=LANGID,eq,\(langid)"
        return RestApi.getRecords(url: url)
    }

    static func update(item: MLangBlog) -> Single<()> {
        // SQL: UPDATE LANGBLOGS SET BLOGGROUPID=?, TITLE=?, CONTENT=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGS/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString()!).map { print($0) }
    }

    static func create(item: MLangBlog) -> Single<Int> {
        // SQL: INSERT INTO BLOGGROUPS (BLOGGROUPID, TITLE, CONTENT) VALUES (?,?,?)
        let url = "\(CommonApi.urlAPI)LANGBLOGS"
        return RestApi.create(url: url, body: try! item.toJSONString()!).map { Int($0)! }.do(onSuccess: { print($0) })
    }
}
