//
//  MTextbookWord.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

import ObjectMapper

@objcMembers
class MTextbookWord: NSObject, Mappable {
    var TEXTBOOKID: Int?
    var LANGID: Int?
    var TEXTBOOKNAME: String?
    var UNITWORDID: Int?
    var UNIT: Int?
    var PART: Int?
    var SEQNUM: Int?
    var WORD: String?
    var NOTE: String?
    
    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        TEXTBOOKID <- map["TEXTBOOKID"]
        LANGID <- map["LANGID"]
        TEXTBOOKNAME <- map["TEXTBOOKNAME"]
        UNITWORDID <- map["UNITWORDID"]
        UNIT <- map["UNIT"]
        PART <- map["PART"]
        SEQNUM <- map["SEQNUM"]
        WORD <- map["WORD"]
        NOTE <- map["NOTE"]
    }

    static func getDataByLang(_ langid: Int, complete: @escaping ([MTextbookWord]) -> Void) {
        // SQL: SELECT * FROM VTEXTBOOKWORDS WHERE LANGID = ?
        let url = "\(RestApi.url)VTEXTBOOKWORDS?transform=1&filter=LANGID,eq,\(langid)"
        RestApi.getArray(url: url, keyPath: "VTEXTBOOKWORDS", complete: complete)
    }
}
