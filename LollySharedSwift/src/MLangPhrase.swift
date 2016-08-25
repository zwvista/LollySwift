//
//  MLangPhrase.swift
//  LollySharedSwift
//
//  Created by 趙偉 on 2016/07/07.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

public class MLangPhrase: DBObject {
    public var PHRASE: String?
    public var TRANSLATION: String?
    
    static func getDataByLang(langid: Int) -> [MLangPhrase] {
        let sql = "SELECT PHRASE, TRANSLATION FROM LANGPHRASES WHERE LANGID = ?"
        let results = try! DBObject.dbCore.executeQuery(sql, langid)
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }
}
