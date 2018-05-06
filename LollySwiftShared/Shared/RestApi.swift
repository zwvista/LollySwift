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
import RxSwift
import RxAlamofire

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

    static func getArray<T: Mappable>(url: String, keyPath: String, type: T.Type) -> Observable<[T]> {
        print("[RestApi]GET:\(url)")
        return RxAlamofireObjectMapper.array(.get, url, keyPath: keyPath)
    }
    static func update(url: String, body: String) -> Observable<String> {
        print("[RestApi]PUT:\(url) BODY:\(body)")
        return RxAlamofire.string(.put, url, encoding: body)
    }
    static func create(url: String, body: String) -> Observable<String> {
        print("[RestApi]POST:\(url) BODY:\(body)")
        return RxAlamofire.string(.post, url, encoding: body)
    }
    static func delete(url: String) -> Observable<String> {
        print("[RestApi]DELETE:\(url)")
        return RxAlamofire.string(.delete, url)
    }
    static func getHtml(url: String) -> Observable<String> {
        print("[RestApi]GET:\(url)")
        return RxAlamofire.string(.get, url)
    }
}
