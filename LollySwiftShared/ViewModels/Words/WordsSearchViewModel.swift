//
//  WordsSearchViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2018/04/14.
//  Copyright © 2018年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

class WordsSearchViewModel: WordsBaseViewModel {
    var arrWords = [MUnitWord]()

    public init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> ()) {
        super.init(settings: settings, needCopy: needCopy)
        arrWords.removeAll()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            complete()
        }
    }
}
