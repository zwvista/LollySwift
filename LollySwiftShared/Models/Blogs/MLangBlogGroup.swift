//
//  MLangBlogGroup.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/15.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation

@objcMembers
class MLangBlogGroups: HasRecords {
    typealias RecordType = MLangBlogGroup
    dynamic var records = [MLangBlogGroup]()
}

@objcMembers
class MLangBlogGroup: NSObject, Codable {
    dynamic var ID = 0
    dynamic var LANGID = 0
    dynamic var GROUPNAME = ""
    dynamic var GPID = 0

    enum CodingKeys : String, CodingKey {
        case ID
        case LANGID
        case GROUPNAME = "NAME"
    }

    static func getDataByLang(_ langid: Int) async -> [MLangBlogGroup] {
        // SQL: SELECT * FROM LANGBLOGGROUPS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGGROUPS?filter=LANGID,eq,\(langid)&order=NAME"
        return await RestApi.getRecords(MLangBlogGroups.self, url: url)
    }

    static func getDataByLangPost(langid: Int, postid: Int) async -> [MLangBlogGroup] {
        // SQL: SELECT * FROM VLANGBLOGGP WHERE LANGID=? AND POSTID=?
        let url = "\(CommonApi.urlAPI)VLANGBLOGGP?filter=LANGID,eq,\(langid)&filter=POSTID,eq,\(postid)&order=GROUPNAME"
        let gps = await RestApi.getRecords(MLangBlogGPs.self, url: url)
        return gps.map { o in
            MLangBlogGroup().then {
                $0.ID = o.GROUPID
                $0.LANGID = langid
                $0.GROUPNAME = o.GROUPNAME
                $0.GPID = o.ID
            }
        }
    }

    static func update(item: MLangBlogGroup) async {
        // SQL: UPDATE LANGBLOGGROUPS SET LANGID=?, NAME=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGGROUPS/\(item.ID)"
        print(await RestApi.update(url: url, body: item.toParameters(isSP: false)))
    }

    static func create(item: MLangBlogGroup) async -> Int {
        // SQL: INSERT INTO LANGBLOGGROUPS (LANGID, NAME) VALUES (?,?)
        let url = "\(CommonApi.urlAPI)LANGBLOGGROUPS"
        let id = Int(await RestApi.create(url: url, body: item.toParameters(isSP: false)))!
        print(id)
        return id
    }
}

class MLangBlogGroupEdit {
    let ID: String
    @Published var GROUPNAME: String

    init(x: MLangBlogGroup) {
        ID = "\(x.ID)"
        GROUPNAME = x.GROUPNAME
    }

    func save(to x: MLangBlogGroup) {
        x.GROUPNAME = GROUPNAME
    }
}
