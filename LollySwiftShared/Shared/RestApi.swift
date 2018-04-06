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

// https://stackoverflow.com/questions/27855319/post-request-with-a-simple-string-in-body-with-alamofire
extension String: ParameterEncoding {
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
    
}

class RestApi {
    static let url = "http://13.231.236.234/lolly/api.php/"
    static let cssFolder = "http://13.231.236.234/lolly/css/"

    static func getArray<T: Mappable>(url: String, keyPath: String, complete: @escaping ([T]) -> Void) {
        print("[RestApi]GET:\(url)")
        Alamofire.request(url).responseArray(keyPath: keyPath) { (response: DataResponse<[T]>) in
            let result = response.result.value!
            complete(result)
        }
    }
    
    static func update(url: String, body: String, complete: @escaping (String) -> Void) {
        print("[RestApi]PUT:\(url) BODY:\(body)")
        Alamofire.request(url, method: .put, encoding: body).responseString { (response: DataResponse<String>) in
            let result = response.result.value!
            complete(result)
        }
    }
    
    static func create(url: String, body: String, complete: @escaping (String) -> Void) {
        print("[RestApi]POST:\(url) BODY:\(body)")
        Alamofire.request(url, method: .post, encoding: body).responseString { (response: DataResponse<String>) in
            let result = response.result.value!
            complete(result)
        }
    }
    
    static func delete(url: String, complete: @escaping (String) -> Void) {
        print("[RestApi]DELETE:\(url)")
        Alamofire.request(url, method: .delete).responseString { (response: DataResponse<String>) in
            let result = response.result.value!
            complete(result)
        }
    }
    
    static func getHtml(url: String, complete: @escaping (String) -> Void) {
        Alamofire.request(url).responseString { (response: DataResponse<String>) in
            let result = response.result.value!
            complete(result)
        }
    }
}
