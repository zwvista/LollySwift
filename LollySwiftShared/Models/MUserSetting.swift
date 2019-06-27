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
    var USERID = 0
    var KIND = 0
    var ENTITYID = 0
    var VALUE1: String?
    var VALUE2: String?
    var VALUE3: String?
    var VALUE4: String?

    static func getData(userid: Int) -> Observable<[MUserSetting]> {
        // SQL: SELECT * FROM USERSETTINGS WHERE USERID=?
        let url = "\(CommonApi.url)USERSETTINGS?filter=USERID,eq,\(userid)"
        return RestApi.getRecords(url: url)
    }
    
    static func update(_ id: Int, body: String) -> Observable<()> {
        let url = "\(CommonApi.url)USERSETTINGS/\(id)"
        // SQL: UPDATE USERSETTINGS SET VALUE1=? WHERE ID=?
        // SQL: UPDATE USERSETTINGS SET VALUE2=? WHERE ID=?
        // SQL: UPDATE USERSETTINGS SET VALUE3=? WHERE ID=?
        // SQL: UPDATE USERSETTINGS SET VALUE4=? WHERE ID=?
        return RestApi.update(url: url, body: body).map { print($0) }
    }
    
    static func update(info: MUserSettingInfo, intValue: Int) -> Observable<()> {
        let body = "VALUE\(info.VALUEID)=\(intValue)"
        return update(info.USERSETTINGID, body: body)
    }
    
    static func update(info: MUserSettingInfo, stringValue: String) -> Observable<()> {
        let body = "VALUE\(info.VALUEID)=\(stringValue)"
        return update(info.USERSETTINGID, body: body)
    }
}

struct MUserSettingInfo {
    var USERSETTINGID = 0
    var VALUEID = 0
}
