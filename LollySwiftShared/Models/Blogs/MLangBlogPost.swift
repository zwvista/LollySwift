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

    static func getDataByLang(_ langid: Int) -> Single<[MLangBlogPost]> {
        // SQL: SELECT * FROM LANGBLOGPOSTS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGPOSTS?filter=LANGID,eq,\(langid)&order=TITLE"
        return RestApi.getRecords(url: url)
    }

    static func getDataByLangGroup(langid: Int, groupid: Int) -> Single<[MLangBlogPost]> {
        // SQL: SELECT * FROM VLANGBLOGGP WHERE LANGID=? AND GROUPID=?
        let url = "\(CommonApi.urlAPI)VLANGBLOGGP?filter=LANGID,eq,\(langid)&filter=GROUPID,eq,\(groupid)&order=TITLE"
        let gps: Single<[MLangBlogGP]> = RestApi.getRecords(url: url)
        return gps.map { $0.map { o in
            MLangBlogPost().then {
                $0.ID = o.POSTID
                $0.LANGID = langid
                $0.TITLE = o.TITLE
                $0.URL = o.URL
                $0.GPID = o.ID
            }
        }}
    }

    static func update(item: MLangBlogPost) -> Single<()> {
        // SQL: UPDATE LANGBLOGPOSTS SET LANGID=?, TITLE=?, URL=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)LANGBLOGPOSTS/\(item.ID)"
        return RestApi.update(url: url, body: item.toParameters(isSP: false)).map { print($0) }
    }

    static func create(item: MLangBlogPost) -> Single<Int> {
        // SQL: INSERT INTO LANGBLOGPOSTS (LANGID, TITLE, URL) VALUES (?,?,?)
        let url = "\(CommonApi.urlAPI)LANGBLOGPOSTS"
        return RestApi.create(url: url, body: item.toParameters(isSP: false)).map { Int($0)! }.do(onSuccess: { print($0) })
    }
}

class MLangBlogPostEdit {
    let ID: String
    let TITLE: BehaviorRelay<String>
    let URL: BehaviorRelay<String>

    init(x: MLangBlogPost) {
        ID = "\(x.ID)"
        TITLE = BehaviorRelay(value: x.TITLE)
        URL = BehaviorRelay(value: x.URL)
    }

    func save(to x: MLangBlogPost) {
        x.TITLE = TITLE.value
        x.URL = URL.value
    }
}
