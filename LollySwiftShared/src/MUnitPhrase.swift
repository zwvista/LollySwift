//
//  MUnitPhrase.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/07.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

import ObjectMapper

open class MUnitPhrase: Mappable {
    open var ID: Int? = 0
    open var TEXTBOOKID: Int?
    open var UNIT: Int?
    open var PART: Int?
    open var SEQNUM: Int?
    open var PHRASE: String?
    open var TRANSLATION: String?
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
        PHRASE <- map["PHRASE"]
        TRANSLATION <- map["TRANSLATION"]
        UNITPART <- map["UNITPART"]
    }

    static func getDataByTextbook(_ textbookid: Int, unitPartFrom: Int, unitPartTo: Int, completionHandler: @escaping ([MUnitPhrase]) -> Void) {
        // let sql = "SELECT * FROM VUNITPHRASES WHERE TEXTBOOKID=? AND UNITPART BETWEEN ? AND ?"
//        let URL = "http://13.231.236.234/lolly/apimysql.php/VUNITPHRASES?transform=1&filter[]=TEXTBOOKID,eq,\(textbookid)&filter[]=UNITPART,bt,\(unitPartFrom),\(unitPartTo)"
//        return RestApi.requestArray(URL: URL, keyPath: "VUNITPHRASES")
        let URL = "http://13.231.236.234/lolly/apimysql.php/VUNITPHRASES?transform=1&filter[]=TEXTBOOKID,eq,\(textbookid)"
        RestApi.requestArray(URL: URL, keyPath: "VUNITPHRASES") { completionHandler($0.filter{unitPartFrom...unitPartTo ~= $0.UNITPART!}) }
    }

}
