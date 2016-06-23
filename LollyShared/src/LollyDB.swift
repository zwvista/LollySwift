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
    
    deinit {
        db.close()
    }
}
