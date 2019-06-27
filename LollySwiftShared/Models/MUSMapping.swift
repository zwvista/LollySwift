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
    var ID = 0
    var NAME = ""
    var KIND = 0
    var ENTITYID = 0
    var VALUEID = 0

    static let NAME_USLANGID = "USLANGID"
    static let NAME_USROWSPERPAGEOPTIONS = "USROWSPERPAGEOPTIONS"
    static let NAME_USROWSPERPAGE = "USROWSPERPAGE"
    static let NAME_USLEVELCOLORS = "USLEVELCOLORS"
    static let NAME_USSCANINTERVAL = "USSCANINTERVAL"
    static let NAME_USREVIEWINTERVAL = "USREVIEWINTERVAL"

    static func getData() -> Observable<[MUSMapping]> {
        // SQL: SELECT * FROM USMAPPINGS
        let url = "\(CommonApi.url)USMAPPINGS"
        return RestApi.getRecords(url: url)
    }
}
