//
//  WordsTestViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/04/15.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class WordsTestViewModel {
    var arrWords = [MUnitWord]()
    var index = 0
    
    func newTest(settings: SettingsViewModel, disposeBag: DisposeBag) {
        MUnitWord.getDataByTextbook(settings.selectedTextbook, unitPartFrom: settings.USUNITPARTFROM, unitPartTo: settings.USUNITPARTTO).subscribe(onNext: {
            self.arrWords = $0.shuffled()
        }).disposed(by: disposeBag)
    }
    
    func nextWord() -> String {
        let w = arrWords[index].WORD
        index += 1
        return w
    }
}
