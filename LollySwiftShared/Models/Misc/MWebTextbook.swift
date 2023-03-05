//
//  MWebTextbook.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/11/11.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

@objcMembers
class MWebTextbook: NSObject, Codable {
    dynamic var ID = 0
    dynamic var LANGID = 0
    dynamic var TEXTBOOKID = 0
    dynamic var TEXTBOOKNAME = ""
    dynamic var UNIT = 0
    dynamic var TITLE = ""
    dynamic var URL = ""

    static func getDataByLang(_ langid: Int) -> Single<[MWebTextbook]> {
        // SQL: SELECT * FROM VWEBTEXTBOOKS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)VWEBTEXTBOOKS?filter=LANGID,eq,\(langid)"
        return RestApi.getRecords(url: url)
    }

    static func update(item: MWebTextbook) -> Single<()> {
        // SQL: UPDATE WEBTEXTBOOKS SET TEXTBOOKID=?, UNIT=?, TITLE=?, URL=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)WEBTEXTBOOKS/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString()!).map { print($0) }
    }

    static func create(item: MWebTextbook) -> Single<Int> {
        // SQL: INSERT INTO TEXTBOOKS (TEXTBOOKID, UNIT, TITLE, URL) VALUES (?,?,?,?)
        let url = "\(CommonApi.urlAPI)WEBTEXTBOOKS"
        return RestApi.create(url: url, body: try! item.toJSONString()!).map { Int($0)! }.do(onSuccess: { print($0) })
    }
}

class MWebTextbookEdit {
    let ID: String
    let TEXTBOOKNAME: String
    let UNIT: BehaviorRelay<Int>
    let TITLE: BehaviorRelay<String>
    let URL: BehaviorRelay<String>

    init(x: MWebTextbook) {
        ID = "\(x.ID)"
        TEXTBOOKNAME = x.TEXTBOOKNAME
        UNIT = BehaviorRelay(value: x.UNIT)
        TITLE = BehaviorRelay(value: x.TITLE)
        URL = BehaviorRelay(value: x.URL)
    }

    func save(to x: MWebTextbook) {
        x.UNIT = UNIT.value
        x.TITLE = TITLE.value
        x.URL = URL.value
    }
}
