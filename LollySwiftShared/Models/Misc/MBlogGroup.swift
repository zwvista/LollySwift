//
//  MBlogGroup.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/15.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation

@objcMembers
class MBlogGroups: HasRecords {
    typealias RecordType = MBlogGroup
    dynamic var records = [MBlogGroup]()
}

@objcMembers
class MBlogGroup: NSObject, Codable {
    dynamic var ID = 0
    dynamic var LANGID = 0
    dynamic var GROUNAME = ""

    enum CodingKeys : String, CodingKey {
        case ID
        case LANGID
        case GROUNAME = "NAME"
    }

    static func getDataByLang(_ langid: Int) async -> [MBlogGroup] {
        // SQL: SELECT * FROM BLOGGROUPS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)BLOGGROUPS?filter=LANGID,eq,\(langid)"
        return await RestApi.getRecords(MBlogGroups.self, url: url)
    }

    static func update(item: MBlogGroup) async {
        // SQL: UPDATE BLOGGROUPS SET LANGID=?, NAME=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)BLOGGROUPS/\(item.ID)"
        print(await RestApi.update(url: url, body: try! item.toJSONString()!))
    }

    static func create(item: MBlogGroup) async -> Int {
        // SQL: INSERT INTO BLOGGROUPS (ID, LANGID, NAME) VALUES (?,?,?)
        let url = "\(CommonApi.urlAPI)BLOGGROUPS"
        let id = Int(await RestApi.create(url: url, body: try! item.toJSONString()!))!
        print(id)
        return id
    }
}
