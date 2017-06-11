//
//  MLangPhrase.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/07.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

open class MLangPhrase: DBObject {
    open var PHRASE: String?
    open var TRANSLATION: String?
    
    static func getDataByLang(_ langid: Int) -> [MLangPhrase] {
        let sql = "SELECT PHRASE, TRANSLATION FROM LANGPHRASES WHERE LANGID = ?"
        let results = try! DBObject.dbCore.executeQuery(sql, values: [langid])
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }
}
