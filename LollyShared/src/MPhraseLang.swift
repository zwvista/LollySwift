//
//  MPhraseLang.swift
//  LollyShared
//
//  Created by 趙偉 on 2016/07/07.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

public class MPhraseLang: DBObject {
    public var ID = 0
    public var BOOKID = 0
    public var UNIT = 0
    public var PART = 0
    public var SEQNUM = 0
    public var PHRASE: String?
    public var TRANSLATION: String?
    public var BOOKNAME: String?
    
    static func getDataByLang(langid: Int) -> [MPhraseLang] {
        let sql = ["SELECT PHRASES.ID, PHRASES.BOOKID, BOOKS.BOOKNAME, PHRASES.UNIT, PHRASES.PART, PHRASES.SEQNUM, PHRASES.PHRASE,",
            "PHRASES.[TRANSLATION] FROM (PHRASES INNER JOIN BOOKS ON PHRASES.BOOKID = BOOKS.BOOKID)",
            "WHERE (BOOKS.LANGID = ?)"].joinWithSeparator("\n")
        let results = try! DBObject.db.executeQuery(sql, langid)
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }
}
