//
//  MLangBlog.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/15.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation

@objcMembers
class MLangBlogs: HasRecords {
    typealias RecordType = MLangBlog
    dynamic var records = [MLangBlog]()
}

@objcMembers
class MLangBlog: NSObject, Codable {
    dynamic var ID = 0
    dynamic var LANGID = 0
    dynamic var LANGBLOGGROUPID = 0
    dynamic var LANGBLOGGROUPNAME = ""
    dynamic var TITLE = ""
    dynamic var CONTENT = ""

    static func getDataByLang(_ langid: Int) async -> [MLangBlog] {
        // SQL: SELECT * FROM VLANGBLOGS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)VLANGBLOGS?filter=LANGID,eq,\(langid)"
        return await RestApi.getRecords(MLangBlogs.self, url: url)
    }

    static func update(item: MLangBlog) async {
        // SQL: UPDATE LANGBLOGS SET LANGBLOGGROUPID=?, TITLE=?, CONTENT=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGS/\(item.ID)"
        print(await RestApi.update(url: url, body: try! item.toJSONString()!))
    }

    static func create(item: MLangBlog) async -> Int {
        // SQL: INSERT INTO LANGBLOGGROUPS (LANGBLOGGROUPID, TITLE, CONTENT) VALUES (?,?,?)
        let url = "\(CommonApi.urlAPI)LANGBLOGS"
        let id = Int(await RestApi.create(url: url, body: try! item.toJSONString()!))!
        print(id)
        return id
    }
}

class MLangBlogEdit {
    let ID: String
    @Published var LANGBLOGGROUPNAME: String
    @Published var TITLE: String
    @Published var CONTENT: String

    init(x: MLangBlog) {
        ID = "\(x.ID)"
        LANGBLOGGROUPNAME = x.LANGBLOGGROUPNAME
        TITLE = x.TITLE
        CONTENT = x.CONTENT
    }

    func save(to x: MLangBlog) {
        x.LANGBLOGGROUPNAME = LANGBLOGGROUPNAME
        x.TITLE = TITLE
        x.CONTENT = CONTENT
    }
}
