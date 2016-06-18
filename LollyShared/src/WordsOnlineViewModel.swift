//
//  WordsOnlineViewModel.swift
//  LollyShared
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation

public class WordsOnlineViewModel: NSObject {
    public var arrLanguages: [MLanguage]
    public var currentLangIndex: Int {
        didSet {
            setCurrentLangIndex()
        }
    }
    public var currentLang: MLanguage {
        return arrLanguages[currentLangIndex]
    }
    
    public var arrDictAll = [MDictAll]()
    public var currentDictIndex = 0
    public var currentDict: MDictAll {
        return arrDictAll[currentDictIndex]
    }
    
    public override init() {
        arrLanguages = LollyDB.sharedInstance.languages()
        currentLangIndex = 2
        super.init()
        setCurrentLangIndex()
    }
    
    private func setCurrentLangIndex() {
        let m = arrLanguages[currentLangIndex]
        arrDictAll = LollyDB.sharedInstance.dictAllByLang(m.LANGID)
        currentDictIndex = 0
    }
}
