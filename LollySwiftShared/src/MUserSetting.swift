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

    static func getData(completionHandler: @escaping ([MUserSetting]) -> Void) {
        // let sql = "SELECT * FROM VUSERSETTINGS"
        let URL = "http://13.231.236.234/lolly/apimysql.php/VUSERSETTINGS?transform=1"
        RestApi.requestArray(URL: URL, keyPath: "VUSERSETTINGS", completionHandler: completionHandler)
    }

}
