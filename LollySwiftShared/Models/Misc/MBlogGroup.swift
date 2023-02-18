//
//  MBlogGroup.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/15.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation
import RxSwift

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

    static func getDataByLang(_ langid: Int) -> Single<[MBlogGroup]> {
        // SQL: SELECT * FROM BLOGGROUPS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)BLOGGROUPS?filter=LANGID,eq,\(langid)"
        return RestApi.getRecords(url: url)
    }

    static func update(item: MBlogGroup) -> Single<()> {
        // SQL: UPDATE BLOGGROUPS SET LANGID=?, NAME=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)BLOGGROUPS/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString()!).map { print($0) }
    }

    static func create(item: MBlogGroup) -> Single<Int> {
        // SQL: INSERT INTO BLOGGROUPS (LANGID, NAME) VALUES (?,?)
        let url = "\(CommonApi.urlAPI)BLOGGROUPS"
        return RestApi.create(url: url, body: try! item.toJSONString()!).map { Int($0)! }.do(onSuccess: { print($0) })
    }
}
