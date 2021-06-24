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
    
    init(options: MReviewOptions) {
        self.options = options
        optionsEdit = MReviewOptionsEdit(x: options)
    }
    
    func onOK() {
        optionsEdit.save(to: options)
    }
}
