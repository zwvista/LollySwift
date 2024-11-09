//
//  MUserSetting.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/08/18.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

@objcMembers
class MUserSetting: NSObject, Codable {
    dynamic var ID = 0
    dynamic var USERID = ""
    dynamic var KIND = 0
    dynamic var ENTITYID = 0
    dynamic var VALUE1: String?
    dynamic var VALUE2: String?
    dynamic var VALUE3: String?
    dynamic var VALUE4: String?

    static func getData() -> Single<[MUserSetting]> {
        // SQL: SELECT * FROM USERSETTINGS WHERE USERID=?
        let url = "\(CommonApi.urlAPI)USERSETTINGS?filter=USERID,eq,\(globalUser.userid)"
        return RestApi.getRecords(url: url)
    }

    static func update(_ id: Int, body: Parameters) -> Single<()> {
        let url = "\(CommonApi.urlAPI)USERSETTINGS/\(id)"
        // SQL: UPDATE USERSETTINGS SET VALUE1=? WHERE ID=?
        // SQL: UPDATE USERSETTINGS SET VALUE2=? WHERE ID=?
        // SQL: UPDATE USERSETTINGS SET VALUE3=? WHERE ID=?
        // SQL: UPDATE USERSETTINGS SET VALUE4=? WHERE ID=?
        return RestApi.update(url: url, body: body).map { print($0) }
    }

    static func update(info: MUserSettingInfo, intValue: Int) -> Single<()> {
        let body = ["VALUE\(info.VALUEID)": intValue]
        return update(info.USERSETTINGID, body: body)
    }

    static func update(info: MUserSettingInfo, stringValue: String) -> Single<()> {
        let body = ["VALUE\(info.VALUEID)": stringValue]
        return update(info.USERSETTINGID, body: body)
    }
}

struct MUserSettingInfo {
    var USERSETTINGID = 0
    var VALUEID = 0
}
