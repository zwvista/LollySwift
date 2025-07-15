//
//  MLangBlogPost.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/15.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation

@objcMembers
class MLangBlogPostContents: HasRecords, @unchecked Sendable {
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
        let arr = await RestApi.getRecords(MLangBlogPostContents.self, url: url)
        return arr.isEmpty ? nil : arr[0]
    }

    static func update(item: MLangBlogPostContent) async {
        // SQL: UPDATE LANGBLOGPOSTS SET CONTENT=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGPOSTS/\(item.ID)"
        print(await RestApi.update(url: url, body: item.toParameters(isSP: false)))
    }
}
