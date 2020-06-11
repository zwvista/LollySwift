//
//  RxCodableAlamofire.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2018/05/06.
//  Copyright © 2018年 趙 偉. All rights reserved.
//

import Foundation

import RxSwift
import Alamofire
import RxAlamofire
import CodableAlamofire

class RxCodableAlamofire {
    public static func requestObject<T: Decodable>(_ method: Alamofire.HTTPMethod, _ url: URLConvertible, parameters: [String: Any]? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: [String: String]? = nil, queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, decoder: JSONDecoder = JSONDecoder()) -> Observable<(HTTPURLResponse, T)> {
        SessionManager.default.rx.requestObject(method, url, parameters: parameters, encoding: encoding, headers: headers, queue: queue, keyPath: keyPath, mapToObject: object, decoder: decoder)
    }
    public static func object<T: Decodable>(_ method: Alamofire.HTTPMethod, _ url: URLConvertible, parameters: [String: Any]? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: [String: String]? = nil, queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, decoder: JSONDecoder = JSONDecoder()) -> Observable<T> {
        SessionManager.default.rx.object(method, url, parameters: parameters, encoding: encoding, headers: headers, queue: queue, keyPath: keyPath, mapToObject: object, decoder: decoder)
    }
}

extension Reactive where Base: SessionManager {
    public func requestObject<T: Decodable>(_ method: Alamofire.HTTPMethod, _ url: URLConvertible, parameters: [String: Any]? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: [String: String]? = nil, queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, decoder: JSONDecoder = JSONDecoder()) -> Observable<(HTTPURLResponse, T)> {
        request(method, url, parameters: parameters, encoding: encoding, headers: headers).flatMap { $0.rx.responseObject(queue: queue, keyPath: keyPath, mapToObject: object, decoder: decoder) }
    }
    public func object<T: Decodable>(_ method: Alamofire.HTTPMethod, _ url: URLConvertible, parameters: [String: Any]? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: [String: String]? = nil, queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, decoder: JSONDecoder = JSONDecoder()) -> Observable<T> {
        request(method, url, parameters: parameters, encoding: encoding, headers: headers).flatMap { $0.rx.object(queue: queue, keyPath: keyPath, mapToObject: object, decoder: decoder) }
    }
}

extension ObservableType where E == DataRequest {
    public func responseObject<T: Decodable>(queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, decoder: JSONDecoder = JSONDecoder()) -> Observable<(HTTPURLResponse, T)> {
        flatMap { $0.rx.responseObject(queue: queue, keyPath: keyPath, mapToObject: object, decoder: decoder) }
    }
    public func object<T: Decodable>(queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, decoder: JSONDecoder = JSONDecoder()) -> Observable<T> {
        flatMap { $0.rx.object(queue: queue, keyPath: keyPath, mapToObject: object, decoder: decoder) }
    }
}

extension Reactive where Base: DataRequest {
    public func responseObject<T: Decodable>(queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, decoder: JSONDecoder = JSONDecoder()) -> Observable<(HTTPURLResponse, T)> {
        responseResult(queue: queue, responseSerializer: DataRequest.DecodableObjectSerializer(keyPath, decoder))
    }
    public func object<T: Decodable>(queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, decoder: JSONDecoder = JSONDecoder()) -> Observable<T> {
        result(queue: queue, responseSerializer: DataRequest.DecodableObjectSerializer(keyPath, decoder))
    }
}
