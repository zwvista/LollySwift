//
//  MSelectItem.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2019/02/28.
//  Copyright © 2019 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
class MSelectItem: NSObject {
    var value = 0
    var label = ""

    override init() {
        super.init()
    }

    init(value: Int, label: String) {
        self.value = value
        self.label = label
        super.init()
    }
}

@objcMembers
class MCode: NSObject, Codable {
    var CODE = 0
    var NAME = ""
    static func getData() -> Single<[MCode]> {
        // SQL: SELECT * FROM CODES WHERE KIND = 1
        let url = "\(CommonApi.urlAPI)CODES?filter=KIND,eq,1"
        return RestApi.getRecords(url: url)
    }
}

class MSPResult: NSObject, Codable {
    var NEW_ID: String?
    var result = ""

    override var description: String { try! toJSONString() ?? "" }
}

@objcMembers
class MTransformItem: NSObject {
    dynamic var index = 0
    dynamic var extractor = ""
    dynamic var replacement = ""

    func copy(from x: MTransformItem) {
        index = x.index
        extractor = x.extractor
        replacement = x.replacement
    }
}
