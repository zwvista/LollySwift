//
//  NoteViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/01/06.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class NoteViewModel {

    var vmSettings: SettingsViewModel
    var mDictNote: MDictNote {
        return vmSettings.selectedDictNote
    }
    let disposeBag: DisposeBag!

    init(settings: SettingsViewModel, disposeBag: DisposeBag) {
        vmSettings = settings
        self.disposeBag = disposeBag
    }

    func getNote(word: String) -> Observable<String> {
        guard vmSettings.hasDictNote else { return Observable.empty() }
        let url = mDictNote.urlString(word: word, arrAutoCorrect: vmSettings.arrAutoCorrect)
        return RestApi.getHtml(url: url).map { html in
            print(html)
            return CommonApi.extractText(from: html, transform: self.mDictNote.TRANSFORM!, template: "") { text,_ in text }
        }
    }
    
    func getNotes(wordCount: Int, isNoteEmpty: @escaping (Int) -> Bool, getOne: @escaping (Int) -> Void, allComplete: @escaping () -> Void) {
        guard vmSettings.hasDictNote else {return}
        var i = 0
        var subscription: Disposable?
        subscription = Observable<Int>.interval(Double(mDictNote.WAIT!) / 1000.0, scheduler: MainScheduler.instance).subscribe { _ in
                while i < wordCount && !isNoteEmpty(i) {
                    i += 1
                }
                if i > wordCount {
                    allComplete()
                    subscription?.dispose()
                } else {
                    if i < wordCount {
                        getOne(i)
                    }
                    // wait for the last one to finish
                    i += 1
                }
            }
        subscription?.disposed(by: disposeBag)
    }

}
