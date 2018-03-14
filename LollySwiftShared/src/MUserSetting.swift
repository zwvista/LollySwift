//
//  MUserSetting.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/08/18.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

import ObjectMapper

open class MUserSetting: Mappable {
    open var ID: Int?
    open var USERID: Int?
    open var KIND: Int?
    open var ENTITYID: Int?
    open var VALUE1: String?
    open var VALUE2: String?
    open var VALUE3: String?
    open var VALUE4: String?
    
    static let userid = 1

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

    static func getData(complete: @escaping ([MUserSetting]) -> Void) {
        // SQL: SELECT * FROM USERSETTINGS WHERE USERID=?
        let url = "\(RestApi.url)USERSETTINGS?transform=1&filter=USERID,eq,\(userid)"
        RestApi.getArray(url: url, keyPath: "USERSETTINGS", complete: complete)
    }

    static func update(langid: Int, complete: @escaping (String) -> Void) {
        // SQL: SELECT * FROM VUSERSETTINGS WHERE USERID=? AND KIND=1
        let url = "\(RestApi.url)USERSETTINGS?transform=1&filter[]=USERID,eq,\(userid)&filter[]=KIND,eq,1"
        RestApi.getArray(url: url, keyPath: "USERSETTINGS") { (arr: [MUserSetting]) in
            let id = arr[0].ID!
            let url2 = "\(RestApi.url)USERSETTINGS/\(id)"
            let body = "VALUE1=\(langid)"
            // SQL: UPDATE VUSERSETTINGS SET VALUE1=? WHERE ID=?
            RestApi.update(url: url2, body: body, complete: complete)
        }
    }
    
    static func update(langid: Int, textbookid: Int, complete: @escaping (String) -> Void) {
        // SQL: SELECT * FROM USERSETTINGS WHERE USERID=? AND KIND=2 AND ENTITYID=?
        let url = "\(RestApi.url)USERSETTINGS?transform=1&filter[]=USERID,eq,\(userid)&filter[]=KIND,eq,2&filter[]=ENTITYID,eq,\(langid)"
        RestApi.getArray(url: url, keyPath: "USERSETTINGS") { (arr: [MUserSetting]) in
            let id = arr[0].ID!
            let url2 = "\(RestApi.url)USERSETTINGS/\(id)"
            let body = "VALUE1=\(textbookid)"
            // SQL: UPDATE USERSETTINGS SET VALUE1=? WHERE ID=?
            RestApi.update(url: url2, body: body, complete: complete)
        }
    }
    
    static func update(textbookid: Int, body: String, complete: @escaping (String) -> Void) {
        // SQL: SELECT * FROM USERSETTINGS WHERE USERID=? AND KIND=3 AND ENTITYID=?
        let url = "\(RestApi.url)USERSETTINGS?transform=1&filter[]=USERID,eq,\(userid)&filter[]=KIND,eq,3&filter[]=ENTITYID,eq,\(textbookid)"
        RestApi.getArray(url: url, keyPath: "USERSETTINGS") { (arr: [MUserSetting]) in
            let id = arr[0].ID!
            let url2 = "\(RestApi.url)USERSETTINGS/\(id)"
            // SQL: UPDATE USERSETTINGS SET VALUE1=? WHERE ID=?
            // SQL: UPDATE USERSETTINGS SET VALUE2=? WHERE ID=?
            // SQL: UPDATE USERSETTINGS SET VALUE3=? WHERE ID=?
            // SQL: UPDATE USERSETTINGS SET VALUE4=? WHERE ID=?
            RestApi.update(url: url2, body: body, complete: complete)
        }
    }
    
    static func update(textbookid: Int, usunitfrom: Int, complete: @escaping (String) -> Void) {
        let body = "VALUE1=\(usunitfrom)"
        update(textbookid: textbookid, body: body, complete: complete)
    }
    
    static func update(textbookid: Int, usunitto: Int, complete: @escaping (String) -> Void) {
        let body = "VALUE2=\(usunitto)"
        update(textbookid: textbookid, body: body, complete: complete)
    }
    
    static func update(textbookid: Int, uspartfrom: Int, complete: @escaping (String) -> Void) {
        let body = "VALUE3=\(uspartfrom)"
        update(textbookid: textbookid, body: body, complete: complete)
    }
    
    static func update(textbookid: Int, uspartto: Int, complete: @escaping (String) -> Void) {
        let body = "VALUE4=\(uspartto)"
        update(textbookid: textbookid, body: body, complete: complete)
    }
}
