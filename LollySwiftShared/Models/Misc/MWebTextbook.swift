//
//  MWebTextbook.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/11/11.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation

@objcMembers
class MWebTextbooks: HasRecords {
    typealias RecordType = MWebTextbook
    dynamic var records = [MWebTextbook]()
}

@objcMembers
class MWebTextbook: NSObject, Codable {
    dynamic var ID = 0
    dynamic var LANGID = 0
    dynamic var TEXTBOOKID = 0
    dynamic var TEXTBOOKNAME = ""
    dynamic var UNIT = 0
    dynamic var TITLE = ""
    dynamic var URL = ""

    static func getDataByLang(_ langid: Int) async -> [MWebTextbook] {
        // SQL: SELECT * FROM VWEBTEXTBOOKS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)VWEBTEXTBOOKS?filter=LANGID,eq,\(langid)"
        return await RestApi.getRecords(MWebTextbooks.self, url: url)
    }

    static func update(item: MWebTextbook) async {
        // SQL: UPDATE WEBTEXTBOOKS SET TEXTBOOKID=?, UNIT=?, TITLE=?, URL=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)WEBTEXTBOOKS/\(item.ID)"
        print(await RestApi.update(url: url, body: try! item.toJSONString()!))
    }

    static func create(item: MWebTextbook) async -> Int {
        // SQL: INSERT INTO TEXTBOOKS (TEXTBOOKID, UNIT, TITLE, URL) VALUES (?,?,?,?)
        let url = "\(CommonApi.urlAPI)WEBTEXTBOOKS"
        let id = Int(await RestApi.create(url: url, body: try! item.toJSONString()!))!
        print(id)
        return id
    }
}

class MWebTextbookEdit {
    let ID: String
    let TEXTBOOKNAME: String
    @Published var UNIT: String
    @Published var TITLE: String
    @Published var URL: String

    init(x: MWebTextbook) {
        ID = "\(x.ID)"
        TEXTBOOKNAME = x.TEXTBOOKNAME
        UNIT = "\(x.UNIT)"
        TITLE = x.TITLE
        URL = x.URL
    }

    func save(to x: MWebTextbook) {
        x.UNIT = Int(UNIT)!
        x.TITLE = TITLE
        x.URL = URL
    }
}
