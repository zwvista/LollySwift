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
    dynamic var LANGBLOGGROUPNAME = ""

    enum CodingKeys : String, CodingKey {
        case ID
        case LANGID
        case LANGBLOGGROUPNAME = "NAME"
    }

    static func getDataByLang(_ langid: Int) async -> [MLangBlogGroup] {
        // SQL: SELECT * FROM LANGBLOGGROUPS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGGROUPS?filter=LANGID,eq,\(langid)"
        return await RestApi.getRecords(MLangBlogGroups.self, url: url)
    }

    static func update(item: MLangBlogGroup) async {
        // SQL: UPDATE LANGBLOGGROUPS SET LANGID=?, NAME=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGGROUPS/\(item.ID)"
        print(await RestApi.update(url: url, body: try! item.toJSONString()!))
    }

    static func create(item: MLangBlogGroup) async -> Int {
        // SQL: INSERT INTO LANGBLOGGROUPS (LANGID, NAME) VALUES (?,?)
        let url = "\(CommonApi.urlAPI)LANGBLOGGROUPS"
        let id = Int(await RestApi.create(url: url, body: try! item.toJSONString()!))!
        print(id)
        return id
    }
}

class MLangBlogGroupEdit {
    let ID: String
    @Published var LANGBLOGGROUPNAME: String

    init(x: MLangBlogGroup) {
        ID = "\(x.ID)"
        LANGBLOGGROUPNAME = x.LANGBLOGGROUPNAME
    }

    func save(to x: MLangBlogGroup) {
        x.LANGBLOGGROUPNAME = LANGBLOGGROUPNAME
    }
}
