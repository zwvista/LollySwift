//
//  WordsBaseViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2019/03/22.
//  Copyright © 2019年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

class WordsBaseViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var vmNote: NoteViewModel!
    var mDictNote: MDictNote? {
        return vmNote.mDictNote
    }
    let disposeBag: DisposeBag!

    public init(settings: SettingsViewModel, disposeBag: DisposeBag) {
        vmSettings = settings
        self.disposeBag = disposeBag
        vmNote = NoteViewModel(settings: settings, disposeBag: disposeBag)
        super.init()
    }
}
