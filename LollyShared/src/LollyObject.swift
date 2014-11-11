//
//  LollyObject.swift
//  LollySharedSwift
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation

public class LollyObject: NSObject {
    var db: LollyDB
    public var arrLanguages: [MLanguage]
    public var arrDictAll: [MDictAll]!
    public var currentLangIndex: Int {
        didSet {
            let m = arrLanguages[currentLangIndex]
            arrDictAll = db.dictAllByLang(m.LANGID)
            currentDictIndex = 0
        }
    }
    public var currentDictIndex = 0
    public var currentDict: MDictAll {
        return arrDictAll[currentDictIndex]
    }
    
    public override init() {
        db = LollyDB()
        arrLanguages = db.languages()
        currentLangIndex = 2
    }
    
}
