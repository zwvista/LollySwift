//
//  MTextbookWord.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
class MTextbookWord: NSObject, Codable {
    var ID = 0
    var TEXTBOOKID = 0
    var LANGID = 0
    var TEXTBOOKNAME = ""
    var UNIT = 0
    var PART = 0
    var SEQNUM = 0
    var WORDID = 0
    var WORD = ""
    var NOTE: String?
    var FAMIID = 0
    var LEVEL = 0
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
        case WORDID
        case WORD
        case NOTE
        case FAMIID
        case LEVEL
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
    var WORDNOTE: String {
        return WORD + ((NOTE ?? "").isEmpty ? "" : "(\(NOTE!))")
    }

    public override var description: String {
        return "\(SEQNUM) \(WORD)" + (NOTE?.isEmpty != false ? "" : "(\(NOTE!))")
    }

    static func getDataByLang(_ langid: Int) -> Observable<[MTextbookWord]> {
        // SQL: SELECT * FROM VTEXTBOOKWORDS WHERE LANGID=?
        let url = "\(RestApi.url)VTEXTBOOKWORDS?transform=1&filter=LANGID,eq,\(langid)&order[]=TEXTBOOKID&order[]=UNIT&order[]=PART&order[]=SEQNUM"
        let o: Observable<[MTextbookWord]> = RestApi.getArray(url: url, keyPath: "VTEXTBOOKWORDS")
        return o.map { arr in
            arr.forEach { row in
                row.arrUnits = CommonApi.unitsFrom(info: row.UNITS)
                row.arrParts = CommonApi.partsFrom(parts: row.PARTS)
            }
            return arr
        }
    }
}
