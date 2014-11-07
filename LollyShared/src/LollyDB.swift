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
        let path = NSBundle.mainBundle().resourcePath! + "Lolly.db"
        db = FMDatabase(path:path)
        db.open()
        super.init()
    }
    
    func dictAllByLang(langID:Int) -> [MDictAll] {
        let sql = "SELECT * FROM DICTALL WHERE LANGID = \(langID)"
        let results = self.db.executeQuery(sql)!
        var array = [MDictAll]()
        while results.next() {
            var m = MDictAll()
            m.LANGID = results.intForColumn("LANGID")
            m.DICTTYPENAME = results.stringForColumn("DICTTYPENAME")
            m.DICTNAME = results.stringForColumn("DICTNAME")
            m.URL = results.stringForColumn("URL")
            m.CHCONV = results.stringForColumn("CHCONV")
            m.TRANSFORM_MAC = results.stringForColumn("TRANSFORM_MAC")
            m.TEMPLATE = results.stringForColumn("TEMPLATE")
            array.append(m)
        }
        return array
    }
    
    func languages() -> [MLanguage] {
        let sql = "SELECT * FROM LANGUAGES WHERE LANGID <> 0"
        let results = self.db.executeQuery(sql)!
        var array = [MLanguage]()
        while results.next() {
            var m = MLanguage()
            m.LANGID = results.intForColumn("LANGID")
            m.ENGNAME = results.stringForColumn("ENGNAME")
            array.append(m)
        }
        return array
    }
    
    deinit {
        db.close()
    }
}
