//
//  MUnitPhrase.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/07.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

open class MUnitPhrase: DBObject {
    open var ID = 0
    open var TEXTBOOKID = 0
    open var UNIT = 0
    open var PART = 0
    open var SEQNUM = 0
    open var PHRASE: String?
    open var TRANSLATION: String?
    
    static func getDataByTextbook(_ textbookid: Int, unitPartFrom: Int, unitPartTo: Int) -> [MUnitPhrase] {
        let sql = "SELECT * FROM VUNITPHRASES WHERE TEXTBOOKID=? AND UNIT*10+PART>=? AND UNIT*10+PART<=?"
        let results = try! DBObject.dbCore.executeQuery(sql, values: [textbookid, unitPartFrom, unitPartTo])
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }

}
