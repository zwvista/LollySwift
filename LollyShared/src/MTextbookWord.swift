//
//  MTextbookWord.swift
//  LollyShared
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

public class MTextbookWord: DBObject {
    public var ID = 0
    public var LANGID = 0
    public var TEXTBOOKNAME: String?
    public var UNIT = 0
    public var PART = 0
    public var SEQNUM = 0
    public var WORD: String?
    public var NOTE: String?
    
    static func getDataByLang(langid: Int) -> [MTextbookWord] {
        let sql = "SELECT * FROM VTEXTBOOKWORDS WHERE LANGID = ?"
        let results = try! DBObject.dbCore.executeQuery(sql, langid)
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }
}
