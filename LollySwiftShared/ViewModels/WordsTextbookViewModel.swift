//
//  WordsTextbookViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

class WordsTextbookViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrWords = [MUnitWord]()
    var arrWordsFiltered: [MUnitWord]?
    var vmNote: NoteViewModel!
    var mDictNote: MDictNote? {
        return vmNote.mDictNote
    }

    public init(settings: SettingsViewModel, disposeBag: DisposeBag, complete: @escaping () -> ()) {
        self.vmSettings = settings
        vmNote = NoteViewModel(settings: settings, disposeBag: disposeBag)
        let item = settings.selectedTextbook!
        super.init()
        MUnitWord.getDataByLang(item.LANGID, arrTextbooks: vmSettings.arrTextbooks).subscribe(onNext: {
            self.arrWords = $0
            complete()
        }).disposed(by: disposeBag)
    }
    
    func filterWordsForSearchText(_ searchText: String, scope: String) {
        arrWordsFiltered = arrWords.filter({ (item) -> Bool in
            return item.WORD.contains(searchText)
        })
    }

    func getNote(index: Int) -> Observable<()> {
        let item = arrWords[index]
        return vmNote.getNote(word: item.WORD).flatMap { note -> Observable<()> in
            item.NOTE = note
            return MLangWord.update(item.WORDID, note: note).map { print($0) }
        }
    }
}
