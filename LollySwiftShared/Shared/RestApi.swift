//
//  RestApi.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2017/06/24.
//  Copyright © 2017年 趙 偉. All rights reserved.
//

import Foundation

import Alamofire
import RxSwift
import RxAlamofire

// https://stackoverflow.com/questions/27855319/post-request-with-a-simple-string-in-body-with-alamofire
class StringEncoding: ParameterEncoding {
    let body: String
    
    public init(body: String) {
        self.body = body
    }
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = body.data(using: .utf8, allowLossyConversion: false)
        return request
    }
}

extension Encodable {
    
    public func toJSONString(prettyPrint: Bool = false) throws -> String? {
        let encoder = JSONEncoder()
        if prettyPrint { encoder.outputFormatting = .prettyPrinted }
        let data = try! encoder.encode(self)
        let jsonString = String(data: data, encoding: .utf8)?
            // When posting(creating) a new record, its id must be null.
            // Otherwise the generated id will not be returned.
            .replacingOccurrences(of: #""ID":0,"#, with: "")
            .replacingOccurrences(of: #","ID":0"#, with: "")
        return jsonString
    }
    
    // https://stackoverflow.com/questions/45209743/how-can-i-use-swift-s-codable-to-encode-into-a-dictionary
    public func toParameters() throws -> Parameters {
        let data = try! JSONEncoder().encode(self)
        let dictionary = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
        return dictionary.map { (k, v) in ("P_" + k, v) }
    }
    
}

class RestApi {

    static func getObject<T: Decodable>(url: String, keyPath: String? = nil) -> Observable<T> {
        RxCodableAlamofire.object(.get, url, keyPath: keyPath)
    }
    static func getArray<T: Decodable>(url: String, keyPath: String? = nil) -> Observable<[T]> {
        print("[RestApi]GET:\(url)")
        return RxCodableAlamofire.object(.get, url, keyPath: keyPath)
    }
    static func getRecords<T: Decodable>(url: String) -> Observable<[T]> {
        getArray(url: url, keyPath: "records")
    }
    static func update(url: String, body: String) -> Observable<String> {
        print("[RestApi]PUT:\(url) BODY:\(body)")
        return RxAlamofire.string(.put, url, encoding: StringEncoding(body: body))
    }
    static func create(url: String, body: String) -> Observable<String> {
        print("[RestApi]POST:\(url) BODY:\(body)")
        return RxAlamofire.string(.post, url, encoding: StringEncoding(body: body))
    }
    static func delete(url: String) -> Observable<String> {
        print("[RestApi]DELETE:\(url)")
        return RxAlamofire.string(.delete, url)
    }
    static func getHtml(url: String) -> Observable<String> {
        print("[RestApi]GET:\(url)")
        return RxAlamofire.string(.get, url)
    }
    static func callSP(url: String, parameters: Parameters) -> Observable<MSPResult> {
        print("[RestApi]SP:\(url)")
        let o: Observable<[[MSPResult]]> = RxCodableAlamofire.object(.post, url, parameters: parameters)
        return o.map { $0[0][0] }
    }
}
