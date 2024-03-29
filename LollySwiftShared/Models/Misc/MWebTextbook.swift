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
}
