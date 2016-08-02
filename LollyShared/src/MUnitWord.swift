//
//  MUnitWord.swift
//  LollyShared
//
//  Created by 趙偉 on 2016/06/25.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

public class MUnitWord: DBObject {
    public var ID = 0
    public var TEXTBOOKID = 0
    public var UNIT = 0
    public var PART = 0
    public var SEQNUM = 0
    public var WORD: String?
    public var NOTE: String?

    static func getDataByTextBook(textbookid: Int, unitPartFrom: Int, unitPartTo: Int) -> [MUnitWord] {
        let sql = "SELECT * FROM UNITWORDS WHERE TEXTBOOKID=? AND UNIT*10+PART>=? AND UNIT*10+PART<=?"
        let results = try! DBObject.dbCore.executeQuery(sql, textbookid, unitPartFrom, unitPartTo)
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }
}
