//
//  MLangPhrase.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/07.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

import ObjectMapper

open class MLangPhrase: Mappable {
    open var PHRASE: String?
    open var TRANSLATION: String?
    
    public init() {
        
    }
    
    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        PHRASE <- map["PHRASE"]
        TRANSLATION <- map["TRANSLATION"]
    }
    
    static func getDataByLang(_ langid: Int, completionHandler: @escaping ([MLangPhrase]) -> Void) {
        // let sql = "SELECT PHRASE, TRANSLATION FROM LANGPHRASES WHERE LANGID = ?"
        let URL = "http://13.231.236.234/lolly/apimysql.php/LANGPHRASES?transform=1&&filter=LANGID,eq,\(langid)"
        return RestApi.requestArray(URL: URL, keyPath: "LANGPHRASES", completionHandler: completionHandler)
    }
}
