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
    @objc dynamic var TEMPLATE = ""
    @objc dynamic var URL = ""
    @objc dynamic var sourceWord = ""
    @objc dynamic var sourceText = ""
    var sourceUrl = ""
    @objc dynamic var resultText = ""
    var resultHtml = ""
    @objc dynamic var interimText = ""
    @objc dynamic var interimMaxIndex = 0
    @objc dynamic var interimIndex = 0
    var arrTranformItems = [MTransformItem]()
    var InterimResults = [String]()
    
    func initItems() {
        arrTranformItems = CommonApi.toTransformItems(transform: TRANSFORM)
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
    
    func getHtml() {
        sourceUrl = URL.replacingOccurrences(of: "{0}", with: sourceWord)
        RestApi.getHtml(url: sourceUrl).subscribe(onNext: { self.sourceText = $0 }) ~ rx.disposeBag
    }
    
    func executeTransform() {
        var text = CommonApi.removeReturns(html: sourceText)
        InterimResults = [text]
        for item in arrTranformItems {
            text = CommonApi.doTransform(text: text, item: item)
            InterimResults.append(text)
        }
        interimMaxIndex = InterimResults.count - 1
        resultText = text
        resultHtml = TEMPLATE.isEmpty ? CommonApi.toHtml(text: text) : TEMPLATE.replacingOccurrences(of: "{0}", with: sourceWord)
        .replacingOccurrences(of: "{1}", with: CommonApi.cssFolder)
        .replacingOccurrences(of: "{2}", with: text as String)
    }

}
