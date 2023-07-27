//
//  MLangBlogPost.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/15.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation

@objcMembers
class MLangBlogPosts: HasRecords {
    typealias RecordType = MLangBlogPost
    dynamic var records = [MLangBlogPost]()
}

@objcMembers
class MLangBlogPost: NSObject, Codable {
    dynamic var ID = 0
    dynamic var LANGID = 0
    dynamic var GROUPID = 0
    dynamic var GROUPNAME = ""
    dynamic var TITLE = ""

    static func getDataByLang(_ langid: Int) async -> [MLangBlogPost] {
        // SQL: SELECT * FROM VLANGBLOGS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)VLANGBLOGS?filter=LANGID,eq,\(langid)"
        return await RestApi.getRecords(MLangBlogPosts.self, url: url)
    }

    static func getDataByLangGroup(langid: Int, groupid: Int) async -> [MLangBlogPost] {
        // SQL: SELECT * FROM VLANGBLOGS WHERE LANGID=? AND GROUPID=?
        let url = "\(CommonApi.urlAPI)VLANGBLOGS?filter=LANGID,eq,\(langid)&filter=GROUPID,eq,\(groupid)"
        return await RestApi.getRecords(MLangBlogPosts.self, url: url)
    }

    static func update(item: MLangBlogPost) async {
        // SQL: UPDATE LANGBLOGS SET GROUPID=?, TITLE=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGS/\(item.ID)"
        print(await RestApi.update(url: url, body: try! item.toJSONString()!))
    }

    static func create(item: MLangBlogPost) async -> Int {
        // SQL: INSERT INTO LANGBLOGS (GROUPID, TITLE) VALUES (?,?)
        let url = "\(CommonApi.urlAPI)LANGBLOGS"
        let id = Int(await RestApi.create(url: url, body: try! item.toJSONString()!))!
        print(id)
        return id
    }
}

@objcMembers
class MLangBlogPostsContent: HasRecords {
    typealias RecordType = MLangBlogPostContent
    dynamic var records = [MLangBlogPostContent]()
}

@objcMembers
class MLangBlogPostContent: NSObject, Codable {
    dynamic var ID = 0
    dynamic var TITLE = ""
    dynamic var CONTENT: String? = ""

    static func getDataById(_ id: Int) async -> MLangBlogPostContent? {
        // SQL: SELECT * FROM LANGBLOGS WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGS?filter=ID,eq,\(id)"
        let arr = await RestApi.getRecords(MLangBlogPostsContent.self, url: url)
        return arr.isEmpty ? nil : arr[0]
    }

    static func update(item: MLangBlogPostContent) async {
        // SQL: UPDATE LANGBLOGS SET CONTENT=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGS/\(item.ID)"
        print(await RestApi.update(url: url, body: try! item.toJSONString()!))
    }
}

class MLangBlogPostEdit {
    let ID: String
    @Published var GROUPNAME: String
    @Published var TITLE: String

    init(x: MLangBlogPost) {
        ID = "\(x.ID)"
        GROUPNAME = x.GROUPNAME
        TITLE = x.TITLE
    }

    func save(to x: MLangBlogPost) {
        x.GROUPNAME = GROUPNAME
        x.TITLE = TITLE
    }
}
