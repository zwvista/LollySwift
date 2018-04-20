//
//  MUserSetting.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/08/18.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

import ObjectMapper

@objcMembers
class MUserSetting: NSObject, Mappable {
    var ID = 0
    var USERID: Int?
    var KIND: Int?
    var ENTITYID: Int?
    var VALUE1: String?
    var VALUE2: String?
    var VALUE3: String?
    var VALUE4: String?

    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        ID <- map["ID"]
        USERID <- map["USERID"]
        KIND <- map["KIND"]
        ENTITYID <- map["ENTITYID"]
        VALUE1 <- map["VALUE1"]
        VALUE2 <- map["VALUE2"]
        VALUE3 <- map["VALUE3"]
        VALUE4 <- map["VALUE4"]
    }

    static func getData(userid: Int, complete: @escaping ([MUserSetting]) -> Void) {
        // SQL: SELECT * FROM USERSETTINGS WHERE USERID=?
        let url = "\(RestApi.url)USERSETTINGS?transform=1&filter=USERID,eq,\(userid)"
        RestApi.getArray(url: url, keyPath: "USERSETTINGS", complete: complete)
    }
    
    static func update(_ id: Int, body: String, complete: @escaping (String) -> Void) {
        let url = "\(RestApi.url)USERSETTINGS/\(id)"
        // SQL: UPDATE USERSETTINGS SET VALUE1=? WHERE ID=?
        // SQL: UPDATE USERSETTINGS SET VALUE2=? WHERE ID=?
        // SQL: UPDATE USERSETTINGS SET VALUE3=? WHERE ID=?
        // SQL: UPDATE USERSETTINGS SET VALUE4=? WHERE ID=?
        RestApi.update(url: url, body: body, complete: complete)
    }

    static func update(_ id: Int, langid: Int, complete: @escaping (String) -> Void) {
        let body = "VALUE1=\(langid)"
        update(id, body: body, complete: complete)
    }
    
    static func update(_ id: Int, textbookid: Int, complete: @escaping (String) -> Void) {
        let body = "VALUE1=\(textbookid)"
        update(id, body: body, complete: complete)
    }
    
    static func update(_ id: Int, dictid: Int, complete: @escaping (String) -> Void) {
        let body = "VALUE2=\(dictid)"
        update(id, body: body, complete: complete)
    }
    
    static func update(_ id: Int, dictnoteid: Int, complete: @escaping (String) -> Void) {
        let body = "VALUE3=\(dictnoteid)"
        update(id, body: body, complete: complete)
    }

    static func update(_ id: Int, usunitfrom: Int, complete: @escaping (String) -> Void) {
        let body = "VALUE1=\(usunitfrom)"
        update(id, body: body, complete: complete)
    }
    
    static func update(_ id: Int, uspartfrom: Int, complete: @escaping (String) -> Void) {
        let body = "VALUE2=\(uspartfrom)"
        update(id, body: body, complete: complete)
    }

    static func update(_ id: Int, usunitto: Int, complete: @escaping (String) -> Void) {
        let body = "VALUE3=\(usunitto)"
        update(id, body: body, complete: complete)
    }
    
    static func update(_ id: Int, uspartto: Int, complete: @escaping (String) -> Void) {
        let body = "VALUE4=\(uspartto)"
        update(id, body: body, complete: complete)
    }
}
