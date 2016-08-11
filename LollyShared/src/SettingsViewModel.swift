//
//  SettingsViewModel.swift
//  LollyShared
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation

public class SettingsViewModel: NSObject {
    public var arrLanguages: [MLanguage]
    public var currentLangIndex: Int {
        didSet {
            setCurrentLangIndex()
        }
    }
    public var currentLang: MLanguage {
        return arrLanguages[currentLangIndex]
    }
    
    public var arrDictionary = [MDictionary]()
    public var currentDictIndex = 0
    public var currentDict: MDictionary {
        return arrDictionary[currentDictIndex]
    }
    
    public var arrTextBooks = [MTextBook]()
    public var currentTextBookIndex = 0
    public var currentTextBook: MTextBook {
        return arrTextBooks[currentTextBookIndex]
    }
    
    public override init() {
        arrLanguages = MLanguage.getData()
        currentLangIndex = 2
        super.init()
        setCurrentLangIndex()
    }
    
    private func setCurrentLangIndex() {
        let m = arrLanguages[currentLangIndex]
        arrDictionary = MDictionary.getDataByLang(m.ID)
        currentDictIndex = 0
        arrTextBooks = MTextBook.getDataByLang(m.ID)
        currentTextBookIndex = arrTextBooks.indexOf{ $0.ID == m.USTEXTBOOKID }!
    }
}
