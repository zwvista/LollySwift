//
//  WordsLangDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

@objcMembers
class WordsLangDetailViewController: NSViewController {

    var vm: WordsLangViewModel!
    var complete: (() -> Void)?
    var item: MLangWord!
    var isAdd: Bool!

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfWord: NSTextField!
    @IBOutlet weak var tfNote: NSTextField!
    @IBOutlet weak var tfFamiID: NSTextField!
    @IBOutlet weak var tfLevel: NSTextField!
    @IBOutlet weak var tfAccuracy: NSTextField!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        isAdd = item.ID == 0
    }
    
    override func viewDidAppear() {
        // https://stackoverflow.com/questions/24235815/cocoa-how-to-set-window-title-from-within-view-controller-in-swift
        (item.WORD.isEmpty ? tfWord : tfNote).becomeFirstResponder()
        view.window?.title = isAdd ? "New Word" : item.WORD
    }
    
    @IBAction func clearAccuracy(_ sender: Any) {
        item.CORRECT = 0
        item.TOTAL = 0
        tfAccuracy.stringValue = item.ACCURACY
    }

    @IBAction func okClicked(_ sender: Any) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        item.WORD = vm.vmSettings.autoCorrectInput(text: item.WORD)
        if isAdd {
            vm.arrWords.append(item)
            WordsLangViewModel.create(item: item).subscribe(onNext: {
                self.item.ID = $0
                self.complete?()
            }).disposed(by: disposeBag)
        } else {
            WordsLangViewModel.update(item: item).subscribe {
                self.complete?()
            }.disposed(by: disposeBag)
        }
        dismiss(self)
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
