//
//  MTextbookWord.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

import ObjectMapper

open class MTextbookWord: Mappable {
    open var ID: Int?
    open var LANGID: Int?
    open var TEXTBOOKNAME: String?
    open var UNIT: Int?
    open var PART: Int?
    open var SEQNUM: Int?
    open var WORD: String?
    open var NOTE: String?
    
    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        ID <- map["ID"]
        LANGID <- map["LANGID"]
        TEXTBOOKNAME <- map["TEXTBOOKNAME"]
        UNIT <- map["UNIT"]
        PART <- map["PART"]
        SEQNUM <- map["SEQNUM"]
        WORD <- map["WORD"]
        NOTE <- map["NOTE"]
    }

    static func getDataByLang(_ langid: Int, completionHandler: @escaping ([MTextbookWord]) -> Void) {
        // let sql = "SELECT * FROM VTEXTBOOKWORDS WHERE LANGID = ?"
        let URL = "http://13.231.236.234/lolly/apimysql.php/VTEXTBOOKWORDS?transform=1&&filter=LANGID,eq,\(langid)"
        RestApi.requestArray(URL: URL, keyPath: "VTEXTBOOKWORDS", completionHandler: completionHandler)
    }
}