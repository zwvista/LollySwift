//
//  MUnitWord.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/06/25.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

open class MUnitWord: DBObject {
    open var ID = 0
    open var TEXTBOOKID = 0
    open var UNIT = 0
    open var PART = 0
    open var SEQNUM = 0
    open var WORD: String?
    open var NOTE: String?

    static func getDataByTextbook(_ textbookid: Int, unitPartFrom: Int, unitPartTo: Int) -> [MUnitWord] {
        let sql = "SELECT * FROM UNITWORDS WHERE TEXTBOOKID=? AND UNIT*10+PART>=? AND UNIT*10+PART<=?"
        let results = try! DBObject.dbCore.executeQuery(sql, textbookid as AnyObject, unitPartFrom as AnyObject, unitPartTo as AnyObject)
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }
}
