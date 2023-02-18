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
    dynamic var LANGBLOGGROUPID = 0
    dynamic var LANGBLOGGROUPNAME = ""
    dynamic var TITLE = ""
    dynamic var CONTENT = ""

    static func getDataByLang(_ langid: Int) -> Single<[MLangBlog]> {
        // SQL: SELECT * FROM VLANGBLOGS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)VLANGBLOGS?filter=LANGID,eq,\(langid)"
        return RestApi.getRecords(url: url)
    }

    static func update(item: MLangBlog) -> Single<()> {
        // SQL: UPDATE LANGBLOGS SET LANGBLOGGROUPID=?, TITLE=?, CONTENT=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGS/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString()!).map { print($0) }
    }

    static func create(item: MLangBlog) -> Single<Int> {
        // SQL: INSERT INTO LANGBLOGGROUPS (LANGBLOGGROUPID, TITLE, CONTENT) VALUES (?,?,?)
        let url = "\(CommonApi.urlAPI)LANGBLOGS"
        return RestApi.create(url: url, body: try! item.toJSONString()!).map { Int($0)! }.do(onSuccess: { print($0) })
    }
}

class MLangBlogEdit {
    let ID: String
    let LANGBLOGGROUPNAME: BehaviorRelay<String>
    let TITLE: BehaviorRelay<String>
    let CONTENT: BehaviorRelay<String>

    init(x: MLangBlog) {
        ID = "\(x.ID)"
        LANGBLOGGROUPNAME = BehaviorRelay(value: x.LANGBLOGGROUPNAME)
        TITLE = BehaviorRelay(value: x.TITLE)
        CONTENT = BehaviorRelay(value: x.CONTENT)
    }

    func save(to x: MLangBlog) {
        x.LANGBLOGGROUPNAME = LANGBLOGGROUPNAME.value
        x.TITLE = TITLE.value
        x.CONTENT = CONTENT.value
    }
}
