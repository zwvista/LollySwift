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
    dynamic var TITLE = ""
    dynamic var URL = ""
    dynamic var GPID = 0

    enum CodingKeys : String, CodingKey {
        case ID
        case LANGID
        case TITLE
        case URL
    }

    static func getDataByLang(_ langid: Int) async -> [MLangBlogPost] {
        // SQL: SELECT * FROM LANGBLOGPOSTS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGPOSTS?filter=LANGID,eq,\(langid)&order=TITLE"
        return await RestApi.getRecords(MLangBlogPosts.self, url: url)
    }

    static func getDataByLangGroup(langid: Int, groupid: Int) async -> [MLangBlogPost] {
        // SQL: SELECT * FROM VLANGBLOGGP WHERE LANGID=? AND GROUPID=?
        let url = "\(CommonApi.urlAPI)VLANGBLOGGP?filter=LANGID,eq,\(langid)&filter=GROUPID,eq,\(groupid)&order=TITLE"
        let gps = await RestApi.getRecords(MLangBlogGPs.self, url: url)
        return gps.map { o in
            MLangBlogPost().then {
                $0.ID = o.POSTID
                $0.LANGID = langid
                $0.TITLE = o.TITLE
                $0.URL = o.URL
                $0.GPID = o.ID
            }
        }
    }

    static func update(item: MLangBlogPost) async {
        // SQL: UPDATE LANGBLOGPOSTS SET LANGID=?, TITLE=?, URL=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGPOSTS/\(item.ID)"
        print(await RestApi.update(url: url, body: item.toParameters(isSP: false)))
    }

    static func create(item: MLangBlogPost) async -> Int {
        // SQL: INSERT INTO LANGBLOGPOSTS (LANGID, TITLE, URL) VALUES (?,?,?)
        let url = "\(CommonApi.urlAPI)LANGBLOGPOSTS"
        let id = Int(await RestApi.create(url: url, body: item.toParameters(isSP: false)))!
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
class MLangBlogPostContent: NSObject, Codable, @unchecked Sendable {
    dynamic var ID = 0
    dynamic var TITLE = ""
    dynamic var CONTENT: String? = ""

    static func getDataById(_ id: Int) async -> MLangBlogPostContent? {
        // SQL: SELECT * FROM LANGBLOGPOSTS WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGPOSTS?filter=ID,eq,\(id)"
        let arr = await RestApi.getRecords(MLangBlogPostsContent.self, url: url)
        return arr.isEmpty ? nil : arr[0]
    }

    static func update(item: MLangBlogPostContent) async {
        // SQL: UPDATE LANGBLOGPOSTS SET CONTENT=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGPOSTS/\(item.ID)"
        print(await RestApi.update(url: url, body: item.toParameters(isSP: false)))
    }
}

class MLangBlogPostEdit {
    let ID: String
    @Published var TITLE: String
    @Published var URL: String

    init(x: MLangBlogPost) {
        ID = "\(x.ID)"
        TITLE = x.TITLE
        URL = x.URL
    }

    func save(to x: MLangBlogPost) {
        x.TITLE = TITLE
        x.URL = URL
    }
}
