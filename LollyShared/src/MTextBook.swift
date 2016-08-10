//
//  MTextBook.swift
//  LollyShared
//
//  Created by 趙偉 on 2016/06/09.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

public class MTextBook: DBObject {
    public var ID = 0
    public var LANGID = 0
    public var TEXTBOOKNAME: String?
    public var UNITS = 0
    public var PARTS: String?
    public var USUNITFROM = 0
    public var USPARTFROM = 0
    public var USUNITTO = 0
    public var USPARTTO = 0
    
    public var unitsAsArray: [String] {
        var arr = [String]();
        for i in 1 ... UNITS {
            arr.append("\(i)")
        }
        return arr
    }
    
    public var partsAsArray: [String] {
        return (PARTS?.componentsSeparatedByString(" "))!
    }
    
    static func getDataByLang(langID: Int) -> [MTextBook] {
        let sql = "SELECT * FROM VTEXTBOOKS WHERE LANGID = ?"
        let results = try! DBObject.dbCore.executeQuery(sql, langID)
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }
}
