//
//  MUserSetting.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/08/18.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

open class MUserSetting: DBObject {
    open var ID = 0
    open var USLANGID = 0
    
    static func getData() -> [MUserSetting] {
        let sql = "SELECT * FROM VUSERSETTINGS"
        let results = try! DBObject.dbCore.executeQuery(sql, values: [])
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }

}
