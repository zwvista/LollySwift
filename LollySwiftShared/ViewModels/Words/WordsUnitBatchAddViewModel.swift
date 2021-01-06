//
//  WordsUnitBatchAddViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙　偉 on 2021/01/06.
//  Copyright © 2021 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class WordsUnitBatchAddViewModel: NSObject {
    var vm: WordsUnitViewModel!
    let words = BehaviorRelay(value: "")
    let isOKEnabled = BehaviorRelay(value: false)

    init(vm: WordsUnitViewModel) {
        self.vm = vm
    }
    
    func onOK() -> Observable<()> {
        return Observable.empty()
    }
}
