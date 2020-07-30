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
    
    init(transform: String, template: String, url: String) {
        TRANSFORM = transform
        TEMPLATE = template
        templateText = template
        arrTranformItems = CommonApi.toTransformItems(transform: transform)
    }
    
    func newTransformItem() -> MTransformItem {
        let item = MTransformItem()
        item.index = arrTranformItems.count + 1
        return item
    }

    func moveTransformItem(at oldIndex: Int, to newIndex: Int) {
        let item = arrTranformItems.remove(at: oldIndex)
        arrTranformItems.insert(item, at: newIndex)
    }

    func reindex(complete: @escaping (Int) -> ()) {
        for i in 1...arrTranformItems.count {
            let item = arrTranformItems[i - 1]
            guard item.index != i else {continue}
            item.index = i
            complete(i - 1)
        }
    }

}
