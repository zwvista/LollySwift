//
//  MUserSetting.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/08/18.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
class MUserSetting: NSObject, Codable {
    var ID = 0
    var USERID: Int?
    var KIND: Int?
    var ENTITYID: Int?
    var VALUE1: String?
    var VALUE2: String?
    var VALUE3: String?
    var VALUE4: String?

    static func getData(userid: Int) -> Observable<[MUserSetting]> {
        // SQL: SELECT * FROM USERSETTINGS WHERE USERID=?
        let url = "\(RestApi.url)USERSETTINGS?transform=1&filter=USERID,eq,\(userid)"
        return RestApi.getArray(url: url, keyPath: "USERSETTINGS")
    }
    
    static func update(_ id: Int, body: String) -> Observable<String> {
        let url = "\(RestApi.url)USERSETTINGS/\(id)"
        // SQL: UPDATE USERSETTINGS SET VALUE1=? WHERE ID=?
        // SQL: UPDATE USERSETTINGS SET VALUE2=? WHERE ID=?
        // SQL: UPDATE USERSETTINGS SET VALUE3=? WHERE ID=?
        // SQL: UPDATE USERSETTINGS SET VALUE4=? WHERE ID=?
        return RestApi.update(url: url, body: body)
    }

    static func update(_ id: Int, langid: Int) -> Observable<String> {
        let body = "VALUE1=\(langid)"
        return update(id, body: body)
    }
    
    static func update(_ id: Int, textbookid: Int) -> Observable<String> {
        let body = "VALUE1=\(textbookid)"
        return update(id, body: body)
    }
    
    static func update(_ id: Int, dictpicker: String) -> Observable<String> {
        let body = "VALUE2=\(dictpicker)"
        return update(id, body: body)
    }
    
    static func update(_ id: Int, dictnoteid: Int) -> Observable<String> {
        let body = "VALUE3=\(dictnoteid)"
        return update(id, body: body)
    }

    static func update(_ id: Int, usunitfrom: Int) -> Observable<String> {
        let body = "VALUE1=\(usunitfrom)"
        return update(id, body: body)
    }
    
    static func update(_ id: Int, uspartfrom: Int) -> Observable<String> {
        let body = "VALUE2=\(uspartfrom)"
        return update(id, body: body)
    }

    static func update(_ id: Int, usunitto: Int) -> Observable<String> {
        let body = "VALUE3=\(usunitto)"
        return update(id, body: body)
    }
    
    static func update(_ id: Int, uspartto: Int) -> Observable<String> {
        let body = "VALUE4=\(uspartto)"
        return update(id, body: body)
    }
}
