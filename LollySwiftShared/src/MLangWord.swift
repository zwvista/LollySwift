//
//  MLangWord.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

import ObjectMapper

open class MLangWord: Mappable {
    open var LANGID: Int? = 0
    open var WORD: String?
    
    public init() {
        
    }
    
    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        LANGID <- map["LANGID"]
        WORD <- map["WORD"]
    }
    
    static func getDataByLang(_ langid: Int) -> [MLangWord] {
        // let sql = "SELECT LANGID, WORD FROM LANGWORDS WHERE LANGID = ?"
        let URL = "https://zwvista.000webhostapp.com/lolly/apisqlite.php/LANGWORDS?transform=1&&filter=LANGID,eq,\(langid)"
        return RestApi.getArray(URL: URL, keyPath: "LANGWORDS")
    }
}
