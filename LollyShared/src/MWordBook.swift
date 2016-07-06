//
//  MWordBook.swift
//  LollyShared
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

public class MWordBook: DBObject {
    public var ID = 0
    public var BOOKID = 0
    public var UNIT = 0
    public var PART = 0
    public var SEQNUM = 0
    public var WORD: String?
    public var NOTE: String?
    public var BOOKNAME: String?
    
    static func getDataByLang(langid: Int) -> [MWordBook] {
        let sql = ["SELECT WORDSBOOK.ID, WORDSBOOK.BOOKID, WORDSBOOK.UNIT, WORDSBOOK.PART, ",
            "WORDSBOOK.SEQNUM, WORDSBOOK.WORD, BOOKS.BOOKNAME, WORDSBOOK.[NOTE]  ",
            "FROM (WORDSBOOK INNER JOIN BOOKS ON WORDSBOOK.BOOKID = BOOKS.BOOKID) ",
            "WHERE (BOOKS.LANGID = ?)"].joinWithSeparator("\n")
        let results = try! DBObject.db.executeQuery(sql, langid)
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }
}
