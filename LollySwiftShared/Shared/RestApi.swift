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

extension Encodable {

    public func toJSONString(prettyPrint: Bool = false) throws -> String? {
        let encoder = JSONEncoder()
        if prettyPrint { encoder.outputFormatting = .prettyPrinted }
        let data = try! encoder.encode(self)
        let jsonString = String(data: data, encoding: .utf8)
        return jsonString
    }

    // https://stackoverflow.com/questions/45209743/how-can-i-use-swift-s-codable-to-encode-into-a-dictionary
    public func toParameters(isSP: Bool) -> Parameters {
        let data = try! JSONEncoder().encode(self)
        let dictionary = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Parameters
        if isSP {
            var params = Parameters()
            for (k, v) in dictionary {
                params["P_" + k] = v
            }
            return params
        } else {
            // When posting(creating) a new record, its id must be null.
            // Otherwise the generated id will not be returned.
            return dictionary.filter { !($0.key == "ID" && $0.value as! Int == 0) }
        }
    }

}

class RestApi {

    static func getObject<T: Decodable>(url: String, keyPath: String? = nil) -> Single<T> {
        RxCodableAlamofire.object(.get, url, keyPath: keyPath).asSingle()
    }
    static func getArray<T: Decodable>(url: String, keyPath: String? = nil) -> Single<[T]> {
        print("[RestApi]GET:\(url)")
        return RxCodableAlamofire.object(.get, url, keyPath: keyPath).asSingle()
    }
    static func getRecords<T: Decodable>(url: String) -> Single<[T]> {
        getArray(url: url, keyPath: "records")
    }
    static func update(url: String, body: Parameters) -> Single<String> {
        print("[RestApi]PUT:\(url) BODY:\(body)")
        return RxAlamofire.string(.put, url, parameters: body).asSingle()
    }
    static func create(url: String, body: Parameters) -> Single<String> {
        print("[RestApi]POST:\(url) BODY:\(body)")
        return RxAlamofire.string(.post, url, parameters: body).asSingle()
    }
    static func delete(url: String) -> Single<String> {
        print("[RestApi]DELETE:\(url)")
        return RxAlamofire.string(.delete, url).asSingle()
    }
    static func getHtml(url: String) -> Single<String> {
        print("[RestApi]GET:\(url)")
        return RxAlamofire.string(.get, url).asSingle()
    }
    static func callSP(url: String, parameters: Parameters) -> Single<MSPResult> {
        print("[RestApi]SP:\(url) BODY:\(parameters)")
        let o: Observable<[[MSPResult]]> = RxCodableAlamofire.object(.post, url, parameters: parameters)
        return o.asSingle().map { $0[0][0] }
    }
}
