//
//  MUnitWord.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/06/25.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

import ObjectMapper

open class MUnitWord: Mappable {
    open var ID: Int? = 0
    open var TEXTBOOKID: Int?
    open var UNIT: Int?
    open var PART: Int?
    open var SEQNUM: Int?
    open var WORD: String?
    open var NOTE: String?
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
        WORD <- map["WORD"]
        NOTE <- map["NOTE"]
        UNITPART <- map["UNITPART"]
    }

    static func getDataByTextbook(_ textbookid: Int, unitPartFrom: Int, unitPartTo: Int, completionHandler: @escaping ([MUnitWord]) -> Void) {
        // let sql = "SELECT * FROM VUNITWORDS WHERE TEXTBOOKID=? AND UNITPART BETWEEN ? AND ? ORDER BY UNITPART,SEQNUM"
        let url = "\(RestApi.url)VUNITWORDS?transform=1&filter[]=TEXTBOOKID,eq,\(textbookid)&filter[]=UNITPART,bt,\(unitPartFrom),\(unitPartTo)&order[]=UNITPART&order[]=SEQNUM"
        RestApi.getArray(url: url, keyPath: "VUNITWORDS", completionHandler: completionHandler)
    }
    
    static func update(_ id: Int, seqnum: Int) {
        let url = "\(RestApi.url)UNITWORDS/\(id)"
        let body = "SEQNUM=\(seqnum)"
        RestApi.update(url: url, body: body)
    }
    
    static func update(_ id: Int, unit: Int, part: Int, word: String, note: String) {
        let url = "\(RestApi.url)UNITWORDS/\(id)"
        let m = MUnitWordEdit()
        m.UNIT = unit; m.PART = part; m.WORD = word; m.NOTE = note
        RestApi.update(url: url, body: m.toJSONString(prettyPrint: false)!)
    }
}

open class MUnitWordEdit: Mappable {
    open var UNIT: Int?
    open var PART: Int?
    open var WORD: String?
    open var NOTE: String?
    
    public init() {
    }
    
    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        UNIT <- map["UNIT"]
        PART <- map["PART"]
        WORD <- map["WORD"]
        NOTE <- map["NOTE"]
    }
}
