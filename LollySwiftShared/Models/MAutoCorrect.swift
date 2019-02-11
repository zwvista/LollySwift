//
//  MAutoCorrect.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/10/27.
//  Copyright © 2018 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class MAutoCorrect: Codable {
    var ID = 0
    var LANGID = 0
    var SEQNUM = 0
    var INPUT = ""
    var EXTENDED = ""
    var BASIC = ""
    
    static func getDataByLang(_ langid: Int) -> Observable<[MAutoCorrect]> {
        // SQL: SELECT * FROM AUTOCORRECT WHERE LANGID=?
        let url = "\(RestApi.url)AUTOCORRECT?transform=1&filter=LANGID,eq,\(langid)"
        return RestApi.getArray(url: url, keyPath: "AUTOCORRECT")
    }
    
    static func autoCorrect(text: String, arrAutoCorrect: [MAutoCorrect], colFunc1: (MAutoCorrect) -> String, colFunc2: (MAutoCorrect) -> String) -> String {
        return arrAutoCorrect.reduce(text) { (str, row) in
            str.replacingOccurrences(of: colFunc1(row), with: colFunc2(row))
        }
    }
}
