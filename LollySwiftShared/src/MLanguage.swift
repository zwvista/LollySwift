//
//  MLanguage.swift
//  LollySwiftShared
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation

import ObjectMapper

open class MLanguage: Mappable {
    open var ID: Int?
    open var LANGNAME: String?
    open var USTEXTBOOKID: String?
    open var USDICTID: String?
    
    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        ID <- map["ID"]
        LANGNAME <- map["LANGNAME"]
        USTEXTBOOKID <- map["USTEXTBOOKID"]
        USDICTID <- map["USDICTID"]
    }
    
    static func getData() -> [MLanguage] {
        // let sql = "SELECT * FROM VLANGUAGES WHERE ID <> 0"
        let URL = "https://zwvista.000webhostapp.com/lolly/apisqlite.php/VLANGUAGES?transform=1&&filter=ID,neq,0"
        return RestApi.getArray(URL: URL, keyPath: "VLANGUAGES")
    }
}
