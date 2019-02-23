//
//  MTextbook.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/06/09.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
class MTextbook: NSObject, Codable {
    var ID = 0
    var LANGID = 0
    var TEXTBOOKNAME = ""
    var UNITS = 0
    var PARTS = ""
    var UNITINFO: String? = nil

    enum CodingKeys : String, CodingKey {
        case ID
        case LANGID
        case TEXTBOOKNAME = "NAME"
        case UNITS
        case PARTS
        case UNITINFO
    }

    static func getDataByLang(_ langid: Int) -> Observable<[MTextbook]> {
        // SQL: SELECT * FROM TEXTBOOKS WHERE LANGID=?
        let url = "\(RestApi.url)TEXTBOOKS?transform=1&filter=LANGID,eq,\(langid)"
        return RestApi.getArray(url: url, keyPath: "TEXTBOOKS")
    }
}
