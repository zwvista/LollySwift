//
//  ReviewOptionsViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/08/09.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxRelay

class ReviewOptionsViewModel: NSObject {
    var options: MReviewOptions!
    var optionsEdit: MReviewOptionsEdit!
    var modeEnabled: BehaviorRelay<Bool>
    
    init(options: MReviewOptions) {
        self.options = options
        optionsEdit = MReviewOptionsEdit(x: options)
        modeEnabled = BehaviorRelay(value: !options.isEmbedded)
    }
    
    func onOK() {
        optionsEdit.save(to: options)
    }
}
