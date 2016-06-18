//
//  SelectUnitsViewModel.swift
//  LollyShared
//
//  Created by 趙偉 on 2016/06/09.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

public class SelectUnitsViewModel: NSObject {
    public var arrLanguages: [MLanguage]
    public var currentLangIndex: Int {
        didSet {
            setCurrentLangIndex()
        }
    }
    public var currentLang: MLanguage {
        return arrLanguages[currentLangIndex]
    }
    
    public var arrBooks = [MBook]()
    public var currentBookIndex = 0
    public var currentBook: MBook {
        return arrBooks[currentBookIndex]
    }
    
    public override init() {
        arrLanguages = LollyDB.sharedInstance.languages()
        currentLangIndex = 2
        super.init()
        setCurrentLangIndex()
    }
    
    private func setCurrentLangIndex() {
        let m = arrLanguages[currentLangIndex]
        arrBooks = LollyDB.sharedInstance.booksByLang(m.LANGID)
        currentBookIndex = arrBooks.indexOf{ $0.BOOKID == m.CURBOOKID }!
    }
}
