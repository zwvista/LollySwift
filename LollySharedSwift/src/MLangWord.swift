//
//  MLangWord.swift
//  LollySharedSwift
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

public class MLangWord: DBObject {
    public var LANGID = 0
    public var WORD: String?
    
    static func getDataByLang(langid: Int) -> [MLangWord] {
        let sql = "SELECT LANGID, WORD FROM LANGWORDS WHERE LANGID = ?"
        let results = try! DBObject.dbCore.executeQuery(sql, langid)
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }
}
