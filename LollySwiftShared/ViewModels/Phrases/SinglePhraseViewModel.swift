//
//  SinglePhraseViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/06/25.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxBinding

class SinglePhraseViewModel: NSObject {

    var arrPhrases_ = BehaviorRelay(value: [MUnitPhrase]())
    var arrPhrases: [MUnitPhrase] { get { arrPhrases_.value } set { arrPhrases_.accept(newValue) } }

    init(phrase: String) {
        super.init()
        MUnitPhrase.getDataByLangPhrase(langid: vmSettings.selectedLang.ID, phrase: phrase, arrTextbooks: vmSettings.arrTextbooks).map { [unowned self] in
            arrPhrases = $0
        }.subscribe() ~ rx.disposeBag
    }
}
