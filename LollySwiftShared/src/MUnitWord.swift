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

    static func getDataByTextbook(_ textbookid: Int, unitPartFrom: Int, unitPartTo: Int) -> [MUnitWord] {
        // let sql = "SELECT * FROM VUNITWORDS WHERE TEXTBOOKID=? AND UNITPART BETWEEN ? AND ?"
//        let URL = "https://zwvista.000webhostapp.com/lolly/apisqlite.php/VUNITWORDS?transform=1&filter[]=TEXTBOOKID,eq,\(textbookid)&filter[]=UNITPART,bt,\(unitPartFrom),\(unitPartTo)"
//        return RestApi.getArray(URL: URL, keyPath: "VUNITWORDS")
        let URL = "https://zwvista.000webhostapp.com/lolly/apisqlite.php/VUNITWORDS?transform=1&filter[]=TEXTBOOKID,eq,\(textbookid)"
        return RestApi.getArray(URL: URL, keyPath: "VUNITWORDS").filter{unitPartFrom...unitPartTo ~= $0.UNITPART!}
    }
}
