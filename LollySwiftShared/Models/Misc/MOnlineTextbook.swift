//
//  MOnlineTextbook.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/11/11.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation

@objcMembers
class MOnlineTextbooks: HasRecords, @unchecked Sendable {
    typealias RecordType = MOnlineTextbook
    dynamic var records = [MOnlineTextbook]()
}

@objcMembers
class MOnlineTextbook: NSObject, Codable, @unchecked Sendable {
    dynamic var ID = 0
    dynamic var LANGID = 0
    dynamic var TEXTBOOKID = 0
    dynamic var TEXTBOOKNAME = ""
    dynamic var UNIT = 0
    dynamic var TITLE = ""
    dynamic var URL = ""

    static func getDataByLang(_ langid: Int) async -> [MOnlineTextbook] {
        // SQL: SELECT * FROM VONLINETEXTBOOKS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)VONLINETEXTBOOKS?filter=LANGID,eq,\(langid)"
        return await RestApi.getRecords(MOnlineTextbooks.self, url: url)
    }
}
