//
//  MLanguage.swift
//  LollySwiftShared
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation

@objcMembers
class MLanguages: HasRecords {
    typealias RecordType = MLanguage
    dynamic var records = [MLanguage]()
}

@objcMembers
class MLanguage: NSObject, Codable {
    dynamic var ID = 0
    dynamic var LANGNAME = ""

    override var description: String { LANGNAME }

    enum CodingKeys : String, CodingKey {
        case ID
        case LANGNAME = "NAME"
    }

    static func getData() async -> [MLanguage] {
        // SQL: SELECT * FROM LANGUAGES WHERE ID<>0
        let url = "\(CommonApi.urlAPI)LANGUAGES?filter=ID,neq,0"
        return await RestApi.getRecords(MLanguages.self, url: url)
    }
}
