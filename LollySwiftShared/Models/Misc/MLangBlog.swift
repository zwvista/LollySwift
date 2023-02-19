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
    dynamic var GROUPID = 0
    dynamic var GROUPNAME = ""
    dynamic var TITLE = ""

    static func getDataByLang(_ langid: Int) async -> [MLangBlog] {
        // SQL: SELECT * FROM VLANGBLOGS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)VLANGBLOGS?filter=LANGID,eq,\(langid)"
        return await RestApi.getRecords(MLangBlogs.self, url: url)
    }

    static func getDataByLangGroup(langid: Int, groupId: Int) async -> [MLangBlog] {
        // SQL: SELECT * FROM VLANGBLOGS WHERE LANGID=? AND GROUPID=?
        let url = "\(CommonApi.urlAPI)VLANGBLOGS?filter=LANGID,eq,\(langid)&GROUPID,eq,\(groupId)"
        return await RestApi.getRecords(MLangBlogs.self, url: url)
    }

    static func update(item: MLangBlog) async {
        // SQL: UPDATE LANGBLOGS SET GROUPID=?, TITLE=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGS/\(item.ID)"
        print(await RestApi.update(url: url, body: try! item.toJSONString()!))
    }

    static func create(item: MLangBlog) async -> Int {
        // SQL: INSERT INTO LANGBLOGS (GROUPID, TITLE) VALUES (?,?)
        let url = "\(CommonApi.urlAPI)LANGBLOGS"
        let id = Int(await RestApi.create(url: url, body: try! item.toJSONString()!))!
        print(id)
        return id
    }
}

@objcMembers
class MLangBlogsContent: HasRecords {
    typealias RecordType = MLangBlogContent
    dynamic var records = [MLangBlogContent]()
}

@objcMembers
class MLangBlogContent: NSObject, Codable {
    dynamic var ID = 0
    dynamic var CONTENT = ""

    static func getDataById(_ id: Int) async -> MLangBlogContent? {
        // SQL: SELECT * FROM LANGBLOGS WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGS?filter=ID,eq,\(id)"
        let arr = await RestApi.getRecords(MLangBlogsContent.self, url: url)
        return arr.isEmpty ? nil : arr[0]
    }

    static func update(item: MLangBlogContent) async {
        // SQL: UPDATE LANGBLOGS SET CONTENT=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGS/\(item.ID)"
        print(await RestApi.update(url: url, body: try! item.toJSONString()!))
    }
}

class MLangBlogEdit {
    let ID: String
    @Published var GROUPNAME: String
    @Published var TITLE: String

    init(x: MLangBlog) {
        ID = "\(x.ID)"
        GROUPNAME = x.GROUPNAME
        TITLE = x.TITLE
    }

    func save(to x: MLangBlog) {
        x.GROUPNAME = GROUPNAME
        x.TITLE = TITLE
    }
}
