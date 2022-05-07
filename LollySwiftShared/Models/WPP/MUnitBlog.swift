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
class MUnitBlog: NSObject, Codable {
    dynamic var ID = 0
    dynamic var TEXTBOOKID = 0
    dynamic var UNIT = 0
    dynamic var CONTENT = ""
    
    static func getDataByTextbook(_ textbookid: Int, unit: Int) -> Single<MUnitBlog?> {
        // SQL: SELECT * FROM VUNITBLOGS WHERE TEXTBOOKID=? AND UNIT = ?
        let url = "\(CommonApi.urlAPI)UNITBLOGS?filter=TEXTBOOKID,eq,\(textbookid)&filter=UNIT,eq,\(unit)"
        let o: Single<[MUnitBlog]> = RestApi.getRecords(url: url)
        return o.map { $0.isEmpty ? nil : $0[0] }
    }
    
    private static func create(item: MUnitBlog) -> Single<()> {
        let url = "\(CommonApi.urlAPI)UNITBLOGS"
        return RestApi.create(url: url, body: try! item.toJSONString()!).map { print($0) }
     }
    
    private static func update(item: MUnitBlog) -> Single<()> {
        let url = "\(CommonApi.urlAPI)UNITBLOGS/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString()!).map { print($0) }
     }

    static func update(_ textbookid: Int, unit: Int, content: String) -> Single<()> {
        MUnitBlog.getDataByTextbook(textbookid, unit: unit).flatMap {
            let item = $0 ?? MUnitBlog()
            if item.ID == 0 {
                item.TEXTBOOKID = textbookid
                item.UNIT = unit
            }
            item.CONTENT = content
            return item.ID == 0 ? create(item: item) : update(item: item)
        }
    }
}
