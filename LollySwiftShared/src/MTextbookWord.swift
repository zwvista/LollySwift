//
//  MTextbookWord.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

import ObjectMapper

open class MTextbookWord: NSObject, Mappable {
    open var TEXTBOOKID: Int?
    open var LANGID: Int?
    open var TEXTBOOKNAME: String?
    open var UNITWORDID: Int?
    open var UNIT: Int?
    open var PART: Int?
    open var SEQNUM: Int?
    open var WORD: String?
    open var NOTE: String?
    
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
