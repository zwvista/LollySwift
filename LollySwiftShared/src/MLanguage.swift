//
//  MLanguage.swift
//  LollySwiftShared
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation

open class MLanguage: DBObject {
    open var ID = 0
    open var LANGNAME: String?
    open var USTEXTBOOKID = 0
    open var USDICTID = 0
    
    static func getData() -> [MLanguage] {
        let sql = "SELECT * FROM VLANGUAGES WHERE ID <> 0"
        let results = try! DBObject.dbCore.executeQuery(sql, values: [])
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }
}
