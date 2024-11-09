//
//  RestApi.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2017/06/24.
//  Copyright © 2017年 趙 偉. All rights reserved.
//

import Foundation
import Alamofire

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

protocol HasRecords: Decodable, Sendable {
    associatedtype RecordType
    var records: [RecordType] { get set }
}

class RestApi {

    static func getObject<T: Decodable & Sendable>(url: String) async -> T {
        try! await AF.request(url).serializingDecodable(T.self).value
    }
    static func getRecords<T: HasRecords>(_ t: T.Type, url: String) async -> [T.RecordType] {
        let o: T = await getObject(url: url)
        return o.records
    }
    static func update(url: String, body: Parameters) async -> String {
        print("[RestApi]PUT:\(url) BODY:\(body)")
        return try! await AF.request(url, method: .put, parameters: body).serializingString().value
    }
    static func create(url: String, body: Parameters) async -> String {
        print("[RestApi]POST:\(url) BODY:\(body)")
        return try! await AF.request(url, method: .post, parameters: body).serializingString().value
    }
    static func delete(url: String) async -> String {
        print("[RestApi]DELETE:\(url)")
        return try! await AF.request(url, method: .delete).serializingString().value
    }
    static func getHtml(url: String) async -> String {
        print("[RestApi]GET:\(url)")
        return try! await AF.request(url).serializingString().value
    }
    static func callSP(url: String, parameters: Parameters) async -> MSPResult {
        print("[RestApi]SP:\(url) BODY:\(parameters)")
        let o = try! await AF.request(url, method: .post, parameters: parameters).serializingDecodable([[MSPResult]].self).value
        return o[0][0]
    }
}
