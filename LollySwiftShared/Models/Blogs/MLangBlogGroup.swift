//
//  MLangBlogGroup.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/15.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

@objcMembers
class MLangBlogGroup: NSObject, Codable {
    dynamic var ID = 0
    dynamic var LANGID = 0
    dynamic var GROUPNAME = ""

    enum CodingKeys : String, CodingKey {
        case ID
        case LANGID
        case GROUPNAME = "NAME"
    }

    static func getDataByLang(_ langid: Int) -> Single<[MLangBlogGroup]> {
        // SQL: SELECT * FROM LANGBLOGGROUPS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGGROUPS?filter=LANGID,eq,\(langid)&order=NAME"
        return RestApi.getRecords(url: url)
    }

    static func getDataByLangPost(langid: Int, postid: Int) -> Single<[MLangBlogGroup]> {
        // SQL: SELECT * FROM VLANGBLOGGP WHERE LANGID=? AND POSTID=?
        let url = "\(CommonApi.urlAPI)VLANGBLOGGP?filter=LANGID,eq,\(langid)&filter=POSTID,eq,\(postid)&order=GROUPNAME"
        let gps: Single<[MLangBlogGP]> = RestApi.getRecords(url: url)
        return gps.map { $0.map { o in
            MLangBlogGroup().then {
                $0.ID = o.GROUPID
                $0.LANGID = langid
                $0.GROUPNAME = o.GROUPNAME
            }
        }}
    }

    static func update(item: MLangBlogGroup) -> Single<()> {
        // SQL: UPDATE LANGBLOGGROUPS SET LANGID=?, NAME=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGGROUPS/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString()!).map { print($0) }
    }

    static func create(item: MLangBlogGroup) -> Single<Int> {
        // SQL: INSERT INTO LANGBLOGGROUPS (LANGID, NAME) VALUES (?,?)
        let url = "\(CommonApi.urlAPI)LANGBLOGGROUPS"
        return RestApi.create(url: url, body: try! item.toJSONString()!).map { Int($0)! }.do(onSuccess: { print($0) })
    }
}

class MLangBlogGroupEdit {
    let ID: String
    let GROUPNAME: BehaviorRelay<String>

    init(x: MLangBlogGroup) {
        ID = "\(x.ID)"
        GROUPNAME = BehaviorRelay(value: x.GROUPNAME)
    }

    func save(to x: MLangBlogGroup) {
        x.GROUPNAME = GROUPNAME.value
    }
}
