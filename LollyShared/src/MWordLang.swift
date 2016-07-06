//
//  MWordLang.swift
//  LollyShared
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

public class MWordLang: DBObject {
    public var LANGID = 0
    public var WORD: String?
    
    static func getDataByLang(langid: Int) -> [MWordLang] {
        let sql = "SELECT LANGID, WORD FROM WORDSLANG WHERE LANGID = ?"
        let results = try! DBObject.db.executeQuery(sql, langid)
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }
}
