//
//  MUnitBlog.swift
//  LollySwiftMac
//
//  Created by cho.i on 2022/05/05.
//  Copyright © 2022 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

@objcMembers
class MUnitBlogs: HasRecords {
    typealias RecordType = MUnitBlog
    dynamic var records = [MUnitBlog]()
}

@objcMembers
class MUnitBlog: NSObject, Codable {
    dynamic var ID = 0
    dynamic var TEXTBOOKID = 0
    dynamic var UNIT = 0
    dynamic var CONTENT = ""
    
    static func getDataByTextbook(_ textbookid: Int, unit: Int) async -> MUnitBlog? {
        // SQL: SELECT * FROM VUNITBLOGS WHERE TEXTBOOKID=? AND UNIT = ?
        let url = "\(CommonApi.urlAPI)UNITBLOGS?filter=TEXTBOOKID,eq,\(textbookid)&filter=UNIT,eq,\(unit)"
        let o = await RestApi.getRecords(MUnitBlogs.self, url: url)
        return o.isEmpty ? nil : o[0]
    }
    
    private static func create(item: MUnitBlog) async {
        let url = "\(CommonApi.urlAPI)UNITBLOGS"
        print(await RestApi.create(url: url, body: try! item.toJSONString()!))
     }
    
    private static func update(item: MUnitBlog) async {
        let url = "\(CommonApi.urlAPI)UNITBLOGS/\(item.ID)"
        print(await RestApi.update(url: url, body: try! item.toJSONString()!))
     }

    static func update(_ textbookid: Int, unit: Int, content: String) async {
        let o = await MUnitBlog.getDataByTextbook(textbookid, unit: unit)
        let item = o ?? MUnitBlog()
        if item.ID == 0 {
            item.TEXTBOOKID = textbookid
            item.UNIT = unit
        }
        item.CONTENT = content
        item.ID == 0 ? await create(item: item) : await update(item: item)
    }
}
