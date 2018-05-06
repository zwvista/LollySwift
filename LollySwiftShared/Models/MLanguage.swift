//
//  MLanguage.swift
//  LollySwiftShared
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation

import ObjectMapper

@objcMembers
class MLanguage: NSObject, Mappable {
    var ID = 0
    var LANGNAME = ""
    
    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        ID <- map["ID"]
        LANGNAME <- map["NAME"]
    }
    
    static func getData(complete: @escaping ([MLanguage]) -> Void) {
        // SQL: SELECT * FROM LANGUAGES WHERE ID <> 0
        let url = "\(RestApi.url)LANGUAGES?transform=1&filter=ID,neq,0"
        // RestApi.getArray(url: url, keyPath: "LANGUAGES", complete: complete)
        RestApi.getArray(url: url, keyPath: "LANGUAGES", type: MLanguage.self).subscribe(onNext: complete)
    }
}
