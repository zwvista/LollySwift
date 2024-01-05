//
//  MUnitBlogPost.swift
//  LollySwiftMac
//
//  Created by cho.i on 2022/05/05.
//  Copyright © 2022 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

@objcMembers
class MUnitBlogPost: NSObject, Codable {
    dynamic var ID = 0
    dynamic var TEXTBOOKID = 0
    dynamic var UNIT = 0
    dynamic var CONTENT = ""

    static func getDataByTextbook(_ textbookid: Int, unit: Int) -> Single<MUnitBlogPost?> {
        // SQL: SELECT * FROM UNITBLOGPOSTS WHERE TEXTBOOKID=? AND UNIT = ?
        let url = "\(CommonApi.urlAPI)UNITBLOGPOSTS?filter=TEXTBOOKID,eq,\(textbookid)&filter=UNIT,eq,\(unit)"
        let o: Single<[MUnitBlogPost]> = RestApi.getRecords(url: url)
        return o.map { $0.isEmpty ? nil : $0[0] }
    }

    private static func create(item: MUnitBlogPost) -> Single<()> {
        let url = "\(CommonApi.urlAPI)UNITBLOGPOSTS"
        return RestApi.create(url: url, body: item.toParameters(isSP: false)).map { print($0) }
     }

    private static func update(item: MUnitBlogPost) -> Single<()> {
        let url = "\(CommonApi.urlAPI)UNITBLOGPOSTS/\(item.ID)"
        return RestApi.update(url: url, body: item.toParameters(isSP: false)).map { print($0) }
     }

    static func update(_ textbookid: Int, unit: Int, content: String) -> Single<()> {
        MUnitBlogPost.getDataByTextbook(textbookid, unit: unit).flatMap {
            let item = $0 ?? MUnitBlogPost()
            if item.ID == 0 {
                item.TEXTBOOKID = textbookid
                item.UNIT = unit
            }
            item.CONTENT = content
            return item.ID == 0 ? create(item: item) : update(item: item)
        }
    }
}
