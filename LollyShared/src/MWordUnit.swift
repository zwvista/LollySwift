//
//  MWordUnit.swift
//  LollyShared
//
//  Created by 趙偉 on 2016/06/25.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

public class MWordUnit: DBObject {
    public var ID = 0
    public var BOOKID = 0
    public var UNIT = 0
    public var PART = 0
    public var SEQNUM = 0
    public var WORD: String?
    public var NOTE: String?

    static func getDataByBookUnitParts(bookid: Int, unitpartfrom: Int, unitpartto: Int) -> [MWordUnit] {
        let sql = "SELECT * FROM WORDSBOOK WHERE BOOKID=? AND UNIT*10+PART>=? AND UNIT*10+PART<=?"
        let results = try! DBObject.db.executeQuery(sql, bookid, unitpartfrom, unitpartto)
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }
}
