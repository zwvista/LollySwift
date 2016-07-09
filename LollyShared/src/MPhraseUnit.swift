//
//  MPhraseUnit.swift
//  LollyShared
//
//  Created by 趙偉 on 2016/07/07.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

public class MPhraseUnit: DBObject {
    public var ID = 0
    public var BOOKID = 0
    public var UNIT = 0
    public var PART = 0
    public var SEQNUM = 0
    public var PHRASE: String?
    public var TRANSLATION: String?
    
    static func getDataByBook(bookid: Int, unitPartFrom: Int, unitPartTo: Int) -> [MPhraseUnit] {
        let sql = "SELECT * FROM PHRASES WHERE BOOKID=? AND UNIT*10+PART>=? AND UNIT*10+PART<=?"
        let results = try! DBObject.db.executeQuery(sql, bookid, unitPartFrom, unitPartTo)
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }

}
