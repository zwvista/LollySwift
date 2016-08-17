//
//  MLanguage.swift
//  LollyShared
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation

public class MLanguage: DBObject {
    public var ID = 0
    public var LANGNAME: String?
    public var USTEXTBOOKID = 0
    public var USDICTID = 0
    
    static func getData() -> [MLanguage] {
        let sql = "SELECT * FROM VLANGUAGES WHERE ID <> 0"
        let results = try! DBObject.dbCore.executeQuery(sql)
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }
}
