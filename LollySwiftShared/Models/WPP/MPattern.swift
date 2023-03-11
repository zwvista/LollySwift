//
//  MPattern.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/07.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

@objcMembers
class MPatterns: HasRecords {
    typealias RecordType = MPattern
    dynamic var records = [MPattern]()
}

@objcMembers
class MPattern: NSObject, Codable {
    dynamic var ID = 0
    dynamic var LANGID = 0
    dynamic var PATTERN = ""
    dynamic var TAGS = ""
    dynamic var TITLE = ""
    dynamic var URL = ""

    static func getDataByLang(_ langid: Int) async -> [MPattern] {
        // SQL: SELECT * FROM PATTERNS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)PATTERNS?filter=LANGID,eq,\(langid)&order=PATTERN"
        return await RestApi.getRecords(MPatterns.self, url: url)
    }
}
