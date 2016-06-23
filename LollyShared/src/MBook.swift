//
//  MBook.swift
//  LollyShared
//
//  Created by 趙偉 on 2016/06/09.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

public class MBook: DBObject {
    public var BOOKID = 0
    public var LANGID = 0
    public var BOOKNAME: String?
    public var UNITSINBOOK = 0
    public var PARTS: String?
    public var UNITFROM = 0
    public var PARTFROM = 0
    public var UNITTO = 0
    public var PARTTO = 0
    
    public var unitsAsArray: [String] {
        var arr = [String]();
        for i in 1 ... UNITSINBOOK {
            arr.append("\(i)")
        }
        return arr
    }
    
    public var partsAsArray: [String] {
        return (PARTS?.componentsSeparatedByString(" "))!
    }
    
    static func dataByLang(langID: Int) -> [MBook] {
        let sql = "SELECT * FROM BOOKS WHERE LANGID = ?"
        let results = try! DBObject.db.executeQuery(sql, langID)
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }
}
