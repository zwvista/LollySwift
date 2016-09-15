//
//  MTextbook.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/06/09.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

open class MTextbook: DBObject {
    open var ID = 0
    open var LANGID = 0
    open var TEXTBOOKNAME: String?
    open var UNITS = 0
    open var PARTS: String?
    open var USUNITFROM = 0
    open var USPARTFROM = 0
    open var USUNITTO = 0
    open var USPARTTO = 0
    
    open var isSingleUnitPart: Bool {
        return USUNITFROM == USUNITTO && USPARTFROM == USPARTTO
    }
    
    static func getDataByLang(_ langID: Int) -> [MTextbook] {
        let sql = "SELECT * FROM VTEXTBOOKS WHERE LANGID = ?"
        let results = try! DBObject.dbCore.executeQuery(sql, langID as AnyObject)
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }
}
