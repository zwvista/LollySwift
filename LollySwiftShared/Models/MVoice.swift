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
class MVoice: NSObject, Codable {
    var ID = 0
    var LANGID = 0
    var VOICETYPEID = 0
    var VOICELANG: String? = nil
    var VOICENAME = ""
    
    enum CodingKeys : String, CodingKey {
        case ID
        case LANGID
        case VOICETYPEID
        case VOICELANG
        case VOICENAME
    }

    static func getDataByLang(_ langid: Int) -> Observable<[MVoice]> {
        // SQL: SELECT * FROM VVOICES WHERE LANGID=?
        let url = "\(RestApi.url)VVOICES?transform=1&filter[]=LANGID,eq,\(langid)"
        return RestApi.getArray(url: url, keyPath: "VVOICES")
    }
}
