//
//  MTextbook.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/06/09.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

import ObjectMapper

open class MTextbook: Mappable {
    open var ID: Int?
    open var LANGID: Int?
    open var NAME: String?
    open var UNITS: Int?
    open var PARTS: String?

    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        ID <- map["ID"]
        LANGID <- map["LANGID"]
        NAME <- map["NAME"]
        UNITS <- map["UNITS"]
        PARTS <- map["PARTS"]
    }
    
    static func getDataByLang(_ langID: Int, complete: @escaping ([MTextbook]) -> Void) {
        // SQL: SELECT * FROM TEXTBOOKS WHERE LANGID = ?
        let url = "\(RestApi.url)TEXTBOOKS?transform=1&&filter=LANGID,eq,\(langID)"
        RestApi.getArray(url: url, keyPath: "TEXTBOOKS", complete: complete)
    }
}
