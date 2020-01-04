//
//  PatternsDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/01/01.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

@objcMembers
class PatternsDetailViewController: NSViewController {
    
    var vm: PatternsViewModel!
    var complete: (() -> Void)?
    var item: MPattern!
    var isAdd: Bool!

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfPattern: NSTextField!
    @IBOutlet weak var tfNote: NSTextField!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        isAdd = item.ID == 0
    }
    
    override func viewDidAppear() {
        // https://stackoverflow.com/questions/24235815/cocoa-how-to-set-window-title-from-within-view-controller-in-swift
        (item.PATTERN.isEmpty ? tfPattern : tfNote).becomeFirstResponder()
        view.window?.title = isAdd ? "New Pattern" : item.PATTERN
    }
    
    @IBAction func okClicked(_ sender: AnyObject) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        item.PATTERN = vm.vmSettings.autoCorrectInput(text: item.PATTERN)
        if isAdd {
            vm.arrPatterns.append(item)
            PatternsViewModel.create(item: item).subscribe(onNext: {
                self.item.ID = $0
                self.complete?()
            }).disposed(by: disposeBag)
        } else {
            PatternsViewModel.update(item: item).subscribe {
                self.complete?()
            }.disposed(by: disposeBag)
        }
        dismiss(self)
    }
    
    deinit {
        print("DEBUG: \(self.className) deinit")
    }

}
