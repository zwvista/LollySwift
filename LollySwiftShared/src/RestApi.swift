//
//  RestApi.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2017/06/24.
//  Copyright © 2017年 趙 偉. All rights reserved.
//

import Foundation

import Alamofire
import ObjectMapper
import AlamofireObjectMapper

class RestApi {
    static func requestArray<T: BaseMappable>(URL: String, keyPath: String, completionHandler: @escaping ([T]) -> Void) {
        Alamofire.request(URL).responseArray(keyPath: keyPath) { (response: DataResponse<[T]>) in
            let result = response.result.value!
            completionHandler(result)
        }
    }
}
