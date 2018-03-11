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
    open var TEXTBOOKNAME: String?
    open var UNITS: Int?
    open var PARTS: String?
    open var USUNITFROM_String: String?
    open var USPARTFROM_String: String?
    open var USUNITTO_String: String?
    open var USPARTTO_String: String?
    
    open var USUNITFROM: Int {return USUNITFROM_String!.toInt()!}
    open var USPARTFROM: Int {return USPARTFROM_String!.toInt()!}
    open var USUNITTO: Int {return USUNITTO_String!.toInt()!}
    open var USPARTTO: Int {return USPARTTO_String!.toInt()!}

    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        ID <- map["ID"]
        LANGID <- map["LANGID"]
        TEXTBOOKNAME <- map["TEXTBOOKNAME"]
        UNITS <- map["UNITS"]
        PARTS <- map["PARTS"]
        USUNITFROM_String <- map["USUNITFROM"]
        USPARTFROM_String <- map["USPARTFROM"]
        USUNITTO_String <- map["USUNITTO"]
        USPARTTO_String <- map["USPARTTO"]
    }

    open var isSingleUnitPart: Bool {
        return USUNITFROM_String == USUNITTO_String && USPARTFROM_String == USPARTTO_String
    }
    
    static func getDataByLang(_ langID: Int, completionHandler: @escaping ([MTextbook]) -> Void) {
        // let sql = "SELECT * FROM VTEXTBOOKS WHERE LANGID = ?"
        let URL = "http://13.231.236.234/lolly/apimysql.php/VTEXTBOOKS?transform=1&&filter=LANGID,eq,\(langID)"
        RestApi.getArray(URL: URL, keyPath: "VTEXTBOOKS", completionHandler: completionHandler)
    }
}
