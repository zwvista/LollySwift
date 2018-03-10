//
//  MUnitWord.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/06/25.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

import ObjectMapper

open class MUnitWord: Mappable {
    open var ID: Int? = 0
    open var TEXTBOOKID: Int?
    open var UNIT: Int?
    open var PART: Int?
    open var SEQNUM: Int?
    open var WORD: String?
    open var NOTE: String?
    open var UNITPART: Int?
    
    public init() {
        
    }
    
    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        ID <- map["ID"]
        TEXTBOOKID <- map["TEXTBOOKID"]
        UNIT <- map["UNIT"]
        PART <- map["PART"]
        SEQNUM <- map["SEQNUM"]
        WORD <- map["WORD"]
        NOTE <- map["NOTE"]
        UNITPART <- map["UNITPART"]
    }

    static func getDataByTextbook(_ textbookid: Int, unitPartFrom: Int, unitPartTo: Int, completionHandler: @escaping ([MUnitWord]) -> Void) {
        // let sql = "SELECT * FROM VUNITWORDS WHERE TEXTBOOKID=? AND UNITPART BETWEEN ? AND ?"
//        let URL = "http://13.231.236.234/lolly/apimysql.php/VUNITWORDS?transform=1&filter[]=TEXTBOOKID,eq,\(textbookid)&filter[]=UNITPART,bt,\(unitPartFrom),\(unitPartTo)"
//        return RestApi.requestArray(URL: URL, keyPath: "VUNITWORDS")
        let URL = "http://13.231.236.234/lolly/apimysql.php/VUNITWORDS?transform=1&filter[]=TEXTBOOKID,eq,\(textbookid)"
        RestApi.requestArray(URL: URL, keyPath: "VUNITWORDS") { completionHandler($0.filter{unitPartFrom...unitPartTo ~= $0.UNITPART!}) }
    }
}
