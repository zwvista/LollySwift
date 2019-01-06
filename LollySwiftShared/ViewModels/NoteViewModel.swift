//
//  NoteViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/01/06.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift

//class NoteViewModel {
//
//    var vmSettings: SettingsViewModel
//    var mDictNote: MDictNote? {
//        return vmSettings.selectedDictNote
//    }
//    var arrWords = [String]()
//    var noteFromIndex = 0, noteToIndex = 0, noteIfEmpty = true
//
//    let disposeBag = DisposeBag()
//
//    public init(settings: SettingsViewModel) {
//        self.vmSettings = settings
//    }
//
//    func getNote(index: Int) -> Observable<()> {
//        guard let mDictNote = mDictNote else {return Observable.empty() }
//        let item = arrWords[index]
//        let url = mDictNote.urlString(word: item.WORD, arrAutoCorrect: vmSettings.arrAutoCorrect)
//        return RestApi.getHtml(url: url).concatMap { (html) -> Observable<()> in
//            print(html)
//            item.NOTE = HtmlApi.extractText(from: html, transform: mDictNote.TRANSFORM!, template: "") { text,_ in return text }
//            return WordsUnitViewModel.update(item.ID, note: item.NOTE!)
//        }
//    }
//
//    func getNotes(ifEmpty: Bool, complete: (Int) -> Void) {
//        guard let mDictNote = mDictNote else {return}
//        noteFromIndex = 0; noteToIndex = arrWords.count; noteIfEmpty = ifEmpty
//        complete(mDictNote.WAIT!)
//    }
//
//    func getNextNote(rowComplete: @escaping (Int) -> Void, allComplete: @escaping () -> Void) {
//        if noteIfEmpty {
//            while noteFromIndex < noteToIndex && !(arrWords[noteFromIndex].NOTE ?? "").isEmpty {
//                noteFromIndex += 1
//            }
//        }
//        if noteFromIndex >= noteToIndex {
//            allComplete()
//        } else {
//            let i = noteFromIndex
//            getNote(index: i).subscribe {
//                rowComplete(i)
//                }.disposed(by: disposeBag)
//            noteFromIndex += 1
//        }
//    }
//
//}
