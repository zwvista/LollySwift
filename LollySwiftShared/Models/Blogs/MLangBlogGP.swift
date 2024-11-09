//
//  MLangBlogGP.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/15.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation

@objcMembers
class MLangBlogGPs: HasRecords, @unchecked Sendable {
    typealias RecordType = MLangBlogGP
    dynamic var records = [MLangBlogGP]()
}

@objcMembers
class MLangBlogGP: NSObject, Codable, @unchecked Sendable {
    dynamic var ID = 0
    dynamic var LANGID = 0
    dynamic var GROUPID = 0
    dynamic var POSTID = 0
    dynamic var GROUPNAME = ""
    dynamic var TITLE = ""
    dynamic var URL = ""

    static func create(item: MLangBlogGP) async -> Int {
        // SQL: INSERT INTO LANGBLOGGP (GROUPID, POSTID) VALUES (?,?)
        let url = "\(CommonApi.urlAPI)LANGBLOGGP"
        let id = Int(await RestApi.create(url: url, body: item.toParameters(isSP: false)))!
        print(id)
        return id
    }

    static func delete(_ id: Int) async {
        // SQL: DELETE LANGBLOGGP WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGGP/\(id)"
        print(await RestApi.delete(url: url))
    }
}
