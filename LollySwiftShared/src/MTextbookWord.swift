//
//  MTextbookWord.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

open class MTextbookWord: DBObject {
    open var ID = 0
    open var LANGID = 0
    open var TEXTBOOKNAME: String?
    open var UNIT = 0
    open var PART = 0
    open var SEQNUM = 0
    open var WORD: String?
    open var NOTE: String?
    
    static func getDataByLang(_ langid: Int) -> [MTextbookWord] {
        let sql = "SELECT * FROM VTEXTBOOKWORDS WHERE LANGID = ?"
        let results = try! DBObject.dbCore.executeQuery(sql, values: [langid])
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }
}
