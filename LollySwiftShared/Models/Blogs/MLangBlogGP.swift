//
//  MLangBlogGP.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/15.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

@objcMembers
class MLangBlogGP: NSObject, Codable {
    dynamic var ID = 0
    dynamic var LANGID = 0
    dynamic var GROUPID = 0
    dynamic var POSTID = 0
    dynamic var GROUPNAME = ""
    dynamic var TITLE = ""
    dynamic var URL = ""

    static func create(item: MLangBlogGP) -> Single<Int> {
        // SQL: INSERT INTO LANGBLOGGP (GROUPID, POSTID) VALUES (?,?)
        let url = "\(CommonApi.urlAPI)LANGBLOGGP"
        return RestApi.create(url: url, body: item.toParameters(isSP: false)).map { Int($0)! }.do(onSuccess: { print($0) })
    }

    static func delete(_ id: Int) -> Single<()> {
        // SQL: DELETE LANGBLOGGP WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGGP/\(id)"
        return RestApi.delete(url: url).map { print($0) }
    }
}
