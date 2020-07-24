//
//  MUSMapping.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/06/26.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class MUSMapping: NSObject, Codable {
    dynamic var ID = 0
    dynamic var NAME = ""
    dynamic var KIND = 0
    dynamic var ENTITYID = 0
    dynamic var VALUEID = 0
    dynamic var LEVEL = 0

    static let NAME_USLANGID = "USLANGID"
    static let NAME_USROWSPERPAGEOPTIONS = "USROWSPERPAGEOPTIONS"
    static let NAME_USROWSPERPAGE = "USROWSPERPAGE"
    static let NAME_USLEVELCOLORS = "USLEVELCOLORS"
    static let NAME_USSCANINTERVAL = "USSCANINTERVAL"
    static let NAME_USREVIEWINTERVAL = "USREVIEWINTERVAL"

    static let NAME_USTEXTBOOKID = "USTEXTBOOKID"
    static let NAME_USDICTREFERENCE = "USDICTREFERENCE"
    static let NAME_USDICTNOTE = "USDICTNOTE"
    static let NAME_USDICTSREFERENCE = "USDICTSREFERENCE"
    static let NAME_USDICTTRANSLATION = "USDICTTRANSLATION"
    static let NAME_USMACVOICEID = "USMACVOICEID"
    static let NAME_USIOSVOICEID = "USIOSVOICEID"
    static let NAME_USANDROIDVOICEID = "USANDROIDVOICEID"
    static let NAME_USWEBVOICEID = "USWEBVOICEID"
    static let NAME_USWINDOWSVOICEID = "USWINDOWSVOICEID"

    static let NAME_USUNITFROM = "USUNITFROM"
    static let NAME_USPARTFROM = "USPARTFROM"
    static let NAME_USUNITTO = "USUNITTO"
    static let NAME_USPARTTO = "USPARTTO"

    static func getData() -> Observable<[MUSMapping]> {
        // SQL: SELECT * FROM USMAPPINGS
        let url = "\(CommonApi.url)USMAPPINGS"
        return RestApi.getRecords(url: url)
    }
}
