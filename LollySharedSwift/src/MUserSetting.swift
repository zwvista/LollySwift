//
//  MUserSetting.swift
//  LollyiOSSwift
//
//  Created by 趙偉 on 2016/08/18.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

public class MUserSetting: DBObject {
    public var ID = 0
    public var USLANGID = 0
    
    static func getData() -> [MUserSetting] {
        let sql = "SELECT * FROM VUSERSETTINGS"
        let results = try! DBObject.dbCore.executeQuery(sql)
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }

}
