//
//  MLanguage.swift
//  LollyShared
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation

public class MLanguage: DBObject {
    public var LANGID = 0
    public var LANGNAME: String?
    public var CURBOOKID = 0
    
    static func data() -> [MLanguage] {
        let sql = "SELECT * FROM LANGUAGES WHERE LANGID <> 0"
        let results = try! DBObject.db.executeQuery(sql)
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }
}
