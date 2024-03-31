//
//  TransformDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/29.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class TransformDetailViewModel: NSObject {

    @objc var item: MDictionary!
    @objc dynamic var TEMPLATE = ""
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
        TEMPLATE = item.TEMPLATE
        arrTranformItems = CommonApi.toTransformItems(transform: item.TRANSFORM)
    }

    func newTransformItem() -> MTransformItem {
        let item = MTransformItem()
        item.index = arrTranformItems.count + 1
        return item
    }

    func reindex(complete: @escaping (Int) -> Void) {
        for i in 1...arrTranformItems.count {
            let item = arrTranformItems[i - 1]
            guard item.index != i else {continue}
            item.index = i
            complete(i - 1)
        }
    }

    func updateSourceUrl() {
        sourceUrl = item.URL.replacingOccurrences(of: "{0}", with: sourceWord.urlEncoded())
    }

    func getHtml() -> Single<()> {
        return RestApi.getHtml(url: sourceUrl).map { [unowned self] in sourceText = $0 }
    }

    func executeTransform() {
        var text = CommonApi.removeReturns(html: sourceText)
        InterimResults = [text]
        for item in arrTranformItems {
            text = CommonApi.doTransform(text: text, item: item)
            InterimResults.append(text)
        }
        interimIndex = 0
        interimMaxIndex = InterimResults.count - 1
        interimText = sourceText
        resultText = text
        resultHtml = TEMPLATE.isEmpty ? CommonApi.toHtml(text: text) : CommonApi.applyTemplate(template: TEMPLATE, word: sourceWord, text: text)
    }

    func updateInterimText() {
        interimText = InterimResults[interimIndex]
    }

    func onOK() {
        item.TRANSFORM = arrTranformItems.flatMap { [$0.extractor, $0.replacement] }.joined(separator: "\r\n")
        item.TEMPLATE = TEMPLATE
    }

}
