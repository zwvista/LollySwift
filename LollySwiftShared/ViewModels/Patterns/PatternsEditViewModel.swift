//
//  PatternsEditViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/21.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class PatternsEditViewModel: NSObject {
    var vm: PatternsViewModel!
    var item: MPattern!
    var itemEdit: MPatternEdit!
    var complete: (() -> Void)?
    var isAdd: Bool!

    init(vm: PatternsViewModel, item: MPattern, complete: (() -> Void)?) {
        self.vm = vm
        self.item = item
        self.complete = complete
        itemEdit = MPatternEdit(x: item)
        isAdd = item.ID == 0
    }
    
    func onOK() {
        itemEdit.save(to: item)
        item.PATTERN = vm.vmSettings.autoCorrectInput(text: item.PATTERN)
        if isAdd {
            vm.arrPatterns.append(item)
            PatternsViewModel.create(item: item).subscribe(onNext: {
                self.item.ID = $0
                self.complete?()
            }) ~ rx.disposeBag
        } else {
            PatternsViewModel.update(item: item).subscribe {
                self.complete?()
            } ~ rx.disposeBag
        }
    }
}
