//
//  MTextbookPhrase.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
class MTextbookPhrase: NSObject, Codable {
    var ID = 0
    var TEXTBOOKID = 0
    var LANGID = 0
    var TEXTBOOKNAME = ""
    var UNIT = 0
    var PART = 0
    var SEQNUM = 0
    var PHRASEID = 0
    var PHRASE = ""
    var TRANSLATION: String?
    var UNITS = ""
    var PARTS = ""
    
    enum CodingKeys : String, CodingKey {
        case ID
        case TEXTBOOKID
        case LANGID
        case TEXTBOOKNAME
        case UNIT
        case PART
        case SEQNUM
        case PHRASEID
        case PHRASE
        case TRANSLATION
        case UNITS
        case PARTS
    }

    var arrUnits = [MSelectItem]()
    var arrParts = [MSelectItem]()
    var UNITSTR: String {
        return arrUnits.first { $0.value == UNIT }!.label
    }
    var PARTSTR: String {
        return arrParts.first { $0.value == PART }!.label
    }
    var UNITPARTSEQNUM: String {
        return "\(UNITSTR) \(SEQNUM)\n\(PARTSTR)"
    }

    static func getDataByLang(_ langid: Int) -> Observable<[MTextbookPhrase]> {
        // SQL: SELECT * FROM VTEXTBOOKPHRASES WHERE LANGID=?
        let url = "\(RestApi.url)VTEXTBOOKPHRASES?transform=1&filter=LANGID,eq,\(langid)&order[]=TEXTBOOKID&order[]=UNIT&order[]=PART&order[]=SEQNUM"
        let o: Observable<[MTextbookPhrase]> = RestApi.getArray(url: url, keyPath: "VTEXTBOOKPHRASES")
        return o.map { arr in
            arr.forEach { row in
                row.arrUnits = CommonApi.unitsFrom(info: row.UNITS)
                row.arrParts = CommonApi.partsFrom(parts: row.PARTS)
            }
            return arr
        }
    }
}
