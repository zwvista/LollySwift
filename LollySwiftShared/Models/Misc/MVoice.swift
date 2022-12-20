//
//  MVoice.swift
//  LollySwiftShared
//
//  Created by zhaowei on 2019/03/09.
//  Copyright (c) 2019年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
class MVoice: NSObject, Codable {
    dynamic var ID = 0
    dynamic var LANGID = 0
    dynamic var VOICETYPEID = 0
    dynamic var VOICELANG: String? = nil
    dynamic var VOICENAME = ""

    enum CodingKeys : String, CodingKey {
        case ID
        case LANGID
        case VOICETYPEID
        case VOICELANG
        case VOICENAME
    }

    override var description: String { VOICENAME }

    static func getDataByLang(_ langid: Int) -> Single<[MVoice]> {
        // SQL: SELECT * FROM VVOICES WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)VVOICES?filter=LANGID,eq,\(langid)"
        return RestApi.getRecords(url: url)
    }
}
