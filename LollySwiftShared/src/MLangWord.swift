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
    
    static func getDataByLang(_ langid: Int, completionHandler: @escaping ([MLangWord]) -> Void) {
        // let sql = "SELECT LANGID, WORD FROM LANGWORDS WHERE LANGID = ?"
        let URL = "http://13.231.236.234/lolly/apimysql.php/LANGWORDS?transform=1&&filter=LANGID,eq,\(langid)"
        RestApi.getArray(URL: URL, keyPath: "LANGWORDS", completionHandler: completionHandler)
    }
}
