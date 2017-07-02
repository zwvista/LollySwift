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
    static func getArray<T: BaseMappable>(URL: String, keyPath: String) -> [T] {
        var result: [T]!
        
        var keepAlive = true
        //ロックが解除されるまで待つ
        let runLoop = RunLoop.current
        Alamofire.request(URL).responseArray(keyPath: keyPath) { (response: DataResponse<[T]>) in
            result = response.result.value!
            keepAlive = false
        }
        while keepAlive &&
            runLoop.run(mode: RunLoopMode.defaultRunLoopMode, before: NSDate(timeIntervalSinceNow: 0.1) as Date) {
                // 0.1秒毎の処理なので、処理が止まらない
        }
        return result
    }
}
