//
//  MLanguage.swift
//  LollySwiftShared
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
class MLanguage: NSObject, Codable {
    dynamic var ID = 0
    dynamic var LANGNAME = ""
    
    override var description: String { LANGNAME }
    
    enum CodingKeys : String, CodingKey {
        case ID
        case LANGNAME = "NAME"
    }

    static func getData() -> Observable<[MLanguage]> {
        // SQL: SELECT * FROM LANGUAGES WHERE ID<>0
        let url = "\(CommonApi.url)LANGUAGES?filter=ID,neq,0"
        return RestApi.getRecords(url: url)
    }
}
