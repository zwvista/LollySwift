//
//  MUserSetting.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/08/18.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

import ObjectMapper

open class MUserSetting: Mappable {
    open var ID: Int?
    open var USLANGID: String?
    
    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        ID <- map["ID"]
        USLANGID <- map["USLANGID"]
    }

    static func getData() -> [MUserSetting] {
        // let sql = "SELECT * FROM VUSERSETTINGS"
        let URL = "https://zwvista.000webhostapp.com/lolly/apisqlite.php/VUSERSETTINGS?transform=1"
        return RestApi.getArray(URL: URL, keyPath: "VUSERSETTINGS")
    }

}
