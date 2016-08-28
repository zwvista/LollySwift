//
//  LollyDB.swift
//  LollySwiftShared
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation

class LollyDB: NSObject {
    var dbCore, dbDic: FMDatabase
    
    override init() {
        let path = NSBundle.mainBundle().resourcePath!
        
        dbCore = FMDatabase(path: path + "/LollyCore.db")
        dbCore.open()
        
        dbDic = FMDatabase(path: path + "/LollyDic.db")
        dbDic.open()
        
        super.init()
    }
    
    // https://github.com/hpique/SwiftSingleton
    static let sharedInstance = LollyDB()
    
    deinit {
        dbCore.close()
        dbDic.close()
    }
}
