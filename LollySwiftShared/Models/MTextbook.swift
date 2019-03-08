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
    var UNITS = ""
    var PARTS = ""

    enum CodingKeys : String, CodingKey {
        case ID
        case LANGID
        case TEXTBOOKNAME = "NAME"
        case UNITS
        case PARTS
    }

    var arrUnits = [MSelectItem]()
    var arrParts = [MSelectItem]()

    override var description: String {
        return TEXTBOOKNAME;
    }

    static func getDataByLang(_ langid: Int) -> Observable<[MTextbook]> {
        // SQL: SELECT * FROM TEXTBOOKS WHERE LANGID=?
        let url = "\(RestApi.url)TEXTBOOKS?transform=1&filter=LANGID,eq,\(langid)"
        let o: Observable<[MTextbook]> = RestApi.getArray(url: url, keyPath: "TEXTBOOKS")
        return o.map { arr in
            arr.forEach { row in
                row.arrUnits = CommonApi.unitsFrom(units: row.UNITS)
                row.arrParts = CommonApi.partsFrom(parts: row.PARTS)
            }
            return arr
        }
    }
}
