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
    var mWord: MLangWord!
    var isAdd: Bool!

    @IBOutlet weak var pubLang: NSPopUpButton!
    @IBOutlet weak var pubPart: NSPopUpButton!
    @IBOutlet weak var tfWord: NSTextField!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // not working because this is a view?
        tfWord.becomeFirstResponder()
        isAdd = mWord.ID == 0
    }
    
    @IBAction func okClicked(_ sender: Any) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        if isAdd {
            vm.arrWords.append(mWord)
            WordsLangViewModel.create(item: mWord).subscribe(onNext: {
                self.mWord.ID = $0
                self.complete?()
            }).disposed(by: disposeBag)
        } else {
            WordsLangViewModel.update(item: mWord).subscribe {
                self.complete?()
            }.disposed(by: disposeBag)
        }
        dismiss(self)
    }
}
