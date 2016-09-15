//
//  MLangWord.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

open class MLangWord: DBObject {
    open var LANGID = 0
    open var WORD: String?
    
    static func getDataByLang(_ langid: Int) -> [MLangWord] {
        let sql = "SELECT LANGID, WORD FROM LANGWORDS WHERE LANGID = ?"
        let results = try! DBObject.dbCore.executeQuery(sql, langid as AnyObject)
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }
}
