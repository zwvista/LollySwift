//
//  MUnitBlogPost.swift
//  LollySwiftMac
//
//  Created by cho.i on 2022/05/05.
//  Copyright © 2022 趙偉. All rights reserved.
//

import Foundation

@objcMembers
class MUnitBlogPosts: HasRecords, @unchecked Sendable {
    typealias RecordType = MUnitBlogPost
    dynamic var records = [MUnitBlogPost]()
}

@objcMembers
class MUnitBlogPost: NSObject, Codable, @unchecked Sendable {
    dynamic var ID = 0
    dynamic var TEXTBOOKID = 0
    dynamic var UNIT = 0
    dynamic var CONTENT = ""

    static func getDataByTextbook(_ textbookid: Int, unit: Int) async -> MUnitBlogPost? {
        // SQL: SELECT * FROM UNITBLOGPOSTS WHERE TEXTBOOKID=? AND UNIT = ?
        let url = "\(CommonApi.urlAPI)UNITBLOGPOSTS?filter=TEXTBOOKID,eq,\(textbookid)&filter=UNIT,eq,\(unit)"
        let o = await RestApi.getRecords(MUnitBlogPosts.self, url: url)
        return o.isEmpty ? nil : o[0]
    }

    private static func create(item: MUnitBlogPost) async {
        let url = "\(CommonApi.urlAPI)UNITBLOGPOSTS"
        print(await RestApi.create(url: url, body: item.toParameters(isSP: false)))
     }

    private static func update(item: MUnitBlogPost) async {
        let url = "\(CommonApi.urlAPI)UNITBLOGPOSTS/\(item.ID)"
        print(await RestApi.update(url: url, body: item.toParameters(isSP: false)))
     }

    static func update(_ textbookid: Int, unit: Int, content: String) async {
        let o = await MUnitBlogPost.getDataByTextbook(textbookid, unit: unit)
        let item = o ?? MUnitBlogPost()
        if item.ID == 0 {
            item.TEXTBOOKID = textbookid
            item.UNIT = unit
        }
        item.CONTENT = content
        item.ID == 0 ? await create(item: item) : await update(item: item)
    }
}
