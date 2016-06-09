//
//  LollyDB.swift
//  LollySharedSwift
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
    
    func dictAllByLang(langID: Int) -> [MDictAll] {
        let sql = "SELECT * FROM DICTALL WHERE LANGID = ?"
        let results = try! db.executeQuery(sql, langID)
        var array = [MDictAll]()
        while results.next() {
            let m = MDictAll(databaseResultSet: results)
            array.append(m)
        }
        return array
    }
    
    func languages() -> [MLanguage] {
        let sql = "SELECT * FROM LANGUAGES WHERE LANGID <> 0"
        let results = try! db.executeQuery(sql)
        var array = [MLanguage]()
        while results.next() {
            let m = MLanguage(databaseResultSet: results)
            array.append(m)
        }
        return array
    }
    
    deinit {
        db.close()
    }
}
