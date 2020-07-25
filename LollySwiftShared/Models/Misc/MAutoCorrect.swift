//
//  MAutoCorrect.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/10/27.
//  Copyright © 2018 趙偉. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
class MAutoCorrect: Codable {
    dynamic var ID = 0
    dynamic var LANGID = 0
    dynamic var SEQNUM = 0
    dynamic var INPUT = ""
    dynamic var EXTENDED = ""
    dynamic var BASIC = ""
    
    static func getDataByLang(_ langid: Int) -> Observable<[MAutoCorrect]> {
        // SQL: SELECT * FROM AUTOCORRECT WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)AUTOCORRECT?filter=LANGID,eq,\(langid)"
        return RestApi.getRecords(url: url)
    }
    
    static func autoCorrect(text: String, arrAutoCorrect: [MAutoCorrect], colFunc1: (MAutoCorrect) -> String, colFunc2: (MAutoCorrect) -> String) -> String {
        arrAutoCorrect.reduce(text) { (str, row) in
            str.replacingOccurrences(of: colFunc1(row), with: colFunc2(row))
        }
    }
}
