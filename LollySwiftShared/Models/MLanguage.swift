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
    var ID = 0
    var VOICE: String? = nil
    var LANGNAME = ""
    var safeVoice: String {
        return VOICE ?? ""
    }
    
    enum CodingKeys : String, CodingKey {
        case ID
        case VOICE = "APPLE_VOICE"
        case LANGNAME = "NAME"
    }

    static func getData() -> Observable<[MLanguage]> {
        // SQL: SELECT * FROM LANGUAGES WHERE ID<>0
        let url = "\(RestApi.url)LANGUAGES?transform=1&filter=ID,neq,0"
        return RestApi.getArray(url: url, keyPath: "LANGUAGES")
    }
}
