//
//  MUSMapping.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/06/26.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation

@objcMembers
class MUSMappings: HasRecords, @unchecked Sendable {
    typealias RecordType = MUSMapping
    dynamic var records = [MUSMapping]()
}

class MUSMapping: NSObject, Codable, @unchecked Sendable {
    dynamic var ID = 0
    dynamic var NAME = ""
    dynamic var KIND = 0
    dynamic var ENTITYID = 0
    dynamic var VALUEID = 0
    dynamic var LEVEL = 0

    static let NAME_USLANG = "USLANG"
    static let NAME_USROWSPERPAGEOPTIONS = "USROWSPERPAGEOPTIONS"
    static let NAME_USROWSPERPAGE = "USROWSPERPAGE"
    static let NAME_USLEVELCOLORS = "USLEVELCOLORS"
    static let NAME_USSCANINTERVAL = "USSCANINTERVAL"
    static let NAME_USREVIEWINTERVAL = "USREVIEWINTERVAL"

    static let NAME_USTEXTBOOK = "USTEXTBOOK"
    static let NAME_USDICTREFERENCE = "USDICTREFERENCE"
    static let NAME_USDICTNOTE = "USDICTNOTE"
    static let NAME_USDICTSREFERENCE = "USDICTSREFERENCE"
    static let NAME_USDICTTRANSLATION = "USDICTTRANSLATION"
    static let NAME_USMACVOICE = "USMACVOICE"
    static let NAME_USIOSVOICE = "USIOSVOICE"
    static let NAME_USANDROIDVOICE = "USANDROIDVOICE"
    static let NAME_USWEBVOICE = "USWEBVOICE"
    static let NAME_USWINDOWSVOICE = "USWINDOWSVOICE"

    static let NAME_USUNITFROM = "USUNITFROM"
    static let NAME_USPARTFROM = "USPARTFROM"
    static let NAME_USUNITTO = "USUNITTO"
    static let NAME_USPARTTO = "USPARTTO"

    static func getData() async -> [MUSMapping] {
        // SQL: SELECT * FROM USMAPPINGS
        let url = "\(CommonApi.urlAPI)USMAPPINGS"
        return await RestApi.getRecords(MUSMappings.self, url: url)
    }
}
