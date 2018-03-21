//
//  MLangPhrase.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/07.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

import ObjectMapper

@objcMembers
class MLangPhrase: NSObject, Mappable {
    var PHRASE: String?
    var TRANSLATION: String?
    
    public override init() {
    }
    
    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        PHRASE <- map["PHRASE"]
        TRANSLATION <- map["TRANSLATION"]
    }
    
    static func getDataByLang(_ langid: Int, complete: @escaping ([MLangPhrase]) -> Void) {
        // SQL: SELECT PHRASE, TRANSLATION FROM LANGPHRASES WHERE LANGID = ?
        let url = "\(RestApi.url)LANGPHRASES?transform=1&filter=LANGID,eq,\(langid)"
        RestApi.getArray(url: url, keyPath: "LANGPHRASES", complete: complete)
    }
}
