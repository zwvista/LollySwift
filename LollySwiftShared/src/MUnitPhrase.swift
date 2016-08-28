//
//  MUnitPhrase.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/07.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

public class MUnitPhrase: DBObject {
    public var ID = 0
    public var TEXTBOOKID = 0
    public var UNIT = 0
    public var PART = 0
    public var SEQNUM = 0
    public var PHRASE: String?
    public var TRANSLATION: String?
    
    static func getDataByTextbook(textbookid: Int, unitPartFrom: Int, unitPartTo: Int) -> [MUnitPhrase] {
        let sql = "SELECT * FROM VUNITPHRASES WHERE TEXTBOOKID=? AND UNIT*10+PART>=? AND UNIT*10+PART<=?"
        let results = try! DBObject.dbCore.executeQuery(sql, textbookid, unitPartFrom, unitPartTo)
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }

}
