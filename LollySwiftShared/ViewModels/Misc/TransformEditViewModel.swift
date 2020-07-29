//
//  TransformEditViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/29.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import NSObject_Rx

class TransformEditViewModel: NSObject {
    
    var TRANSFORM = ""
    var TEMPLATE = ""
    @objc dynamic var templateText = ""
    @objc dynamic var sourceURL = ""
    @objc dynamic var sourceText = ""
    @objc dynamic var resultText = ""
    @objc dynamic var interimText = ""
    @objc dynamic var interimMaxIndex = 0
    @objc dynamic var interimIndex = 0
    var arrTranformItems = [MTransformItem]()
    var InterimResults = [String]()
    
    init(transform: String, template: String) {
        TRANSFORM = transform
        TEMPLATE = template
        templateText = template
        arrTranformItems = CommonApi.toTransformItems(transform: transform)
    }

}
