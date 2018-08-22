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
    var TEXTBOOKID = 0
    var LANGID = 0
    var TEXTBOOKNAME = ""
    var UNITWORDID = 0
    var UNIT = 0
    var PART = 0
    var SEQNUM = 0
    var WORD = ""
    var NOTE: String?
    
    public override var description: String {
        return "\(SEQNUM) \(WORD)" + (NOTE?.isEmpty != false ? "" : "(\(NOTE!))")
    }

    static func getDataByLang(_ langid: Int) -> Observable<[MTextbookWord]> {
        // SQL: SELECT * FROM VTEXTBOOKWORDS WHERE LANGID = ?
        let url = "\(RestApi.url)VTEXTBOOKWORDS?transform=1&filter=LANGID,eq,\(langid)"
        return RestApi.getArray(url: url, keyPath: "VTEXTBOOKWORDS", type: MTextbookWord.self)
    }
}
