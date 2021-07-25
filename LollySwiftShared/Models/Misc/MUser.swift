//
//  MUser.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2021/04/09.
//  Copyright © 2021 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
class MUser: NSObject, Codable {
    dynamic var ID = 0
    dynamic var USERID = ""
    dynamic var USERNAME = ""
    dynamic var PASSWORD = ""

    static func getData(username: String, password: String) -> Single<[MUser]> {
        // SQL: SELECT * FROM USERSETTINGS WHERE USERNAME=? AND PASSWORD=?
        let url = "\(CommonApi.urlAPI)USERS?filter=USERNAME,eq,\(username)&filter=PASSWORD,eq,\(password)"
        return RestApi.getRecords(url: url)
    }
}
