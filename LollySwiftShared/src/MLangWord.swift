//
//  MLangWord.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

import ObjectMapper

@objcMembers
class MLangWord: NSObject, Mappable {
    var LANGID: Int? = 0
    var WORD: String?
    
    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        LANGID <- map["LANGID"]
        WORD <- map["WORD"]
    }
    
    static func getDataByLang(_ langid: Int, complete: @escaping ([MLangWord]) -> Void) {
        // SQL: SELECT LANGID, WORD FROM LANGWORDS WHERE LANGID = ?
        let url = "\(RestApi.url)LANGWORDS?transform=1&filter=LANGID,eq,\(langid)"
        RestApi.getArray(url: url, keyPath: "LANGWORDS", complete: complete)
    }
}
