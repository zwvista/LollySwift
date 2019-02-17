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
    var UNITS = 0
    var arrUnits: [String] {
        return (1...UNITS).map { String($0) }
    }
    var PARTS = ""
    var arrParts: [String] {
        return PARTS.split(" ")
    }
    var PARTSTR: String {
        return arrParts[PART - 1]
    }
    var UNITPARTSEQNUM: String {
        return "\(UNIT) \(SEQNUM)\n\(PARTSTR)"
    }

    static func getDataByLang(_ langid: Int) -> Observable<[MTextbookPhrase]> {
        // SQL: SELECT * FROM VTEXTBOOKPHRASES WHERE LANGID=?
        let url = "\(RestApi.url)VTEXTBOOKPHRASES?transform=1&filter=LANGID,eq,\(langid)&order[]=TEXTBOOKID&order[]=UNIT&order[]=PART&order[]=SEQNUM"
        return RestApi.getArray(url: url, keyPath: "VTEXTBOOKPHRASES")
    }
}
