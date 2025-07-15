//
//  MLangBlogPost.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/15.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

@objcMembers
class MLangBlogPostContent: NSObject, Codable {
    dynamic var ID = 0
    dynamic var TITLE = ""
    dynamic var CONTENT: String? = ""

    static func getDataById(_ id: Int) -> Single<MLangBlogPostContent?> {
        // SQL: SELECT * FROM LANGBLOGPOSTS WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGPOSTS?filter=ID,eq,\(id)"
        let o: Single<[MLangBlogPostContent]> = RestApi.getRecords(url: url)
        return o.map { arr in
            arr.isEmpty ? nil : arr[0]
        }
    }

    static func update(item: MLangBlogPostContent) -> Single<()> {
        // SQL: UPDATE LANGBLOGPOSTS SET CONTENT=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGPOSTS/\(item.ID)"
        return RestApi.update(url: url, body: item.toParameters(isSP: false)).map { print($0) }
    }
}
