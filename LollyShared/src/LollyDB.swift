//
//  LollyDB.swift
//  LollyShared
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation

class LollyDB: NSObject {
    var db: FMDatabase
    
    override init() {
        let path = NSBundle.mainBundle().resourcePath! + "/Lolly.db"
        db = FMDatabase(path: path)
        db.open()
        super.init()
    }
    
    // https://github.com/hpique/SwiftSingleton
    static let sharedInstance = LollyDB()
    
    func booksByLang(langID: Int) -> [MBook] {
        let sql = "SELECT * FROM BOOKS WHERE LANGID = ?"
        let results = try! db.executeQuery(sql, langID)
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }
    
    func dictAllByLang(langID: Int) -> [MDictAll] {
        let sql = "SELECT * FROM DICTALL WHERE LANGID = ?"
        let results = try! db.executeQuery(sql, langID)
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }
    
    func languages() -> [MLanguage] {
        let sql = "SELECT * FROM LANGUAGES WHERE LANGID <> 0"
        let results = try! db.executeQuery(sql)
        return DBObject.dataFromResultSet(databaseResultSet: results)
    }
    
    deinit {
        db.close()
    }
}
