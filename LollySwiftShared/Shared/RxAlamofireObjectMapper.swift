//
//  RxAlamofireObjectMapper.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2018/05/06.
//  Copyright © 2018年 趙 偉. All rights reserved.
//

import Foundation

import RxSwift
import Alamofire
import ObjectMapper
import RxAlamofire
import AlamofireObjectMapper

public func requestObject<T: BaseMappable>(_ method: Alamofire.HTTPMethod, _ url: URLConvertible, parameters: [String: Any]? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: [String: String]? = nil, queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil) -> Observable<(HTTPURLResponse, T)> {
    return SessionManager.default.rx.requestObject(method, url, parameters: parameters, encoding: encoding, headers: headers, queue: queue, keyPath: keyPath, mapToObject: object, context: context)
}
public func requestObject<T: ImmutableMappable>(_ method: Alamofire.HTTPMethod, _ url: URLConvertible, parameters: [String: Any]? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: [String: String]? = nil, queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil) -> Observable<(HTTPURLResponse, T)> {
    return SessionManager.default.rx.requestObject(method, url, parameters: parameters, encoding: encoding, headers: headers, queue: queue, keyPath: keyPath, mapToObject: object, context: context)
}
public func requestArray<T: BaseMappable>(_ method: Alamofire.HTTPMethod, _ url: URLConvertible, parameters: [String: Any]? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: [String: String]? = nil, queue: DispatchQueue? = nil, keyPath: String? = nil, context: MapContext? = nil) -> Observable<(HTTPURLResponse, [T])> {
    return SessionManager.default.rx.requestArray(method, url, parameters: parameters, encoding: encoding, headers: headers, queue: queue, keyPath: keyPath, context: context)
}
public func requestArray<T: ImmutableMappable>(_ method: Alamofire.HTTPMethod, _ url: URLConvertible, parameters: [String: Any]? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: [String: String]? = nil, queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil) -> Observable<(HTTPURLResponse, [T])> {
    return SessionManager.default.rx.requestArray(method, url, parameters: parameters, encoding: encoding, headers: headers, queue: queue, keyPath: keyPath, context: context)
}
public func object<T: BaseMappable>(_ method: Alamofire.HTTPMethod, _ url: URLConvertible, parameters: [String: Any]? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: [String: String]? = nil, queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil) -> Observable<T> {
    return SessionManager.default.rx.object(method, url, parameters: parameters, encoding: encoding, headers: headers, queue: queue, keyPath: keyPath, mapToObject: object, context: context)
}
public func object<T: ImmutableMappable>(_ method: Alamofire.HTTPMethod, _ url: URLConvertible, parameters: [String: Any]? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: [String: String]? = nil, queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil) -> Observable<T> {
    return SessionManager.default.rx.object(method, url, parameters: parameters, encoding: encoding, headers: headers, queue: queue, keyPath: keyPath, mapToObject: object, context: context)
}
public func array<T: BaseMappable>(_ method: Alamofire.HTTPMethod, _ url: URLConvertible, parameters: [String: Any]? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: [String: String]? = nil, queue: DispatchQueue? = nil, keyPath: String? = nil, context: MapContext? = nil) -> Observable<[T]> {
    return SessionManager.default.rx.array(method, url, parameters: parameters, encoding: encoding, headers: headers, queue: queue, keyPath: keyPath, context: context)
}
public func array<T: ImmutableMappable>(_ method: Alamofire.HTTPMethod, _ url: URLConvertible, parameters: [String: Any]? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: [String: String]? = nil, queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil) -> Observable<[T]> {
    return SessionManager.default.rx.array(method, url, parameters: parameters, encoding: encoding, headers: headers, queue: queue, keyPath: keyPath, context: context)
}


extension Reactive where Base: SessionManager {
    public func requestObject<T: BaseMappable>(_ method: Alamofire.HTTPMethod, _ url: URLConvertible, parameters: [String: Any]? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: [String: String]? = nil, queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil) -> Observable<(HTTPURLResponse, T)> {
        return request(method, url, parameters: parameters, encoding: encoding, headers: headers).flatMap { $0.rx.responseObject(queue: queue, keyPath: keyPath, mapToObject: object, context: context) }
    }
    public func requestObject<T: ImmutableMappable>(_ method: Alamofire.HTTPMethod, _ url: URLConvertible, parameters: [String: Any]? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: [String: String]? = nil, queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil) -> Observable<(HTTPURLResponse, T)> {
        return request(method, url, parameters: parameters, encoding: encoding, headers: headers).flatMap { $0.rx.responseObject(queue: queue, keyPath: keyPath, mapToObject: object, context: context) }
    }
    public func requestArray<T: BaseMappable>(_ method: Alamofire.HTTPMethod, _ url: URLConvertible, parameters: [String: Any]? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: [String: String]? = nil, queue: DispatchQueue? = nil, keyPath: String? = nil, context: MapContext? = nil) -> Observable<(HTTPURLResponse, [T])> {
        return request(method, url, parameters: parameters, encoding: encoding, headers: headers).flatMap { $0.rx.responseArray(queue: queue, keyPath: keyPath, context: context) }
    }
    public func requestArray<T: ImmutableMappable>(_ method: Alamofire.HTTPMethod, _ url: URLConvertible, parameters: [String: Any]? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: [String: String]? = nil, queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil) -> Observable<(HTTPURLResponse, [T])> {
        return request(method, url, parameters: parameters, encoding: encoding, headers: headers).flatMap { $0.rx.responseArray(queue: queue, keyPath: keyPath, context: context) }
    }
    public func object<T: BaseMappable>(_ method: Alamofire.HTTPMethod, _ url: URLConvertible, parameters: [String: Any]? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: [String: String]? = nil, queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil) -> Observable<T> {
        return request(method, url, parameters: parameters, encoding: encoding, headers: headers).flatMap { $0.rx.object(queue: queue, keyPath: keyPath, mapToObject: object, context: context) }
    }
    public func object<T: ImmutableMappable>(_ method: Alamofire.HTTPMethod, _ url: URLConvertible, parameters: [String: Any]? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: [String: String]? = nil, queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil) -> Observable<T> {
        return request(method, url, parameters: parameters, encoding: encoding, headers: headers).flatMap { $0.rx.object(queue: queue, keyPath: keyPath, mapToObject: object, context: context) }
    }
    public func array<T: BaseMappable>(_ method: Alamofire.HTTPMethod, _ url: URLConvertible, parameters: [String: Any]? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: [String: String]? = nil, queue: DispatchQueue? = nil, keyPath: String? = nil, context: MapContext? = nil) -> Observable<[T]> {
        return request(method, url, parameters: parameters, encoding: encoding, headers: headers).flatMap { $0.rx.array(queue: queue, keyPath: keyPath, context: context) }
    }
    public func array<T: ImmutableMappable>(_ method: Alamofire.HTTPMethod, _ url: URLConvertible, parameters: [String: Any]? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: [String: String]? = nil, queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil) -> Observable<[T]> {
        return request(method, url, parameters: parameters, encoding: encoding, headers: headers).flatMap { $0.rx.array(queue: queue, keyPath: keyPath, context: context) }
    }
}

extension ObservableType where E == DataRequest {
    public func responseObject<T: BaseMappable>(queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil) -> Observable<(HTTPURLResponse, T)> {
        return flatMap { $0.rx.responseObject(queue: queue, keyPath: keyPath, mapToObject: object, context: context) }
    }
    public func responseObject<T: ImmutableMappable>(queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil) -> Observable<(HTTPURLResponse, T)> {
        return flatMap { $0.rx.responseObject(queue: queue, keyPath: keyPath, mapToObject: object, context: context) }
    }
    public func responseArray<T: BaseMappable>(queue: DispatchQueue? = nil, keyPath: String? = nil, context: MapContext? = nil) -> Observable<(HTTPURLResponse, [T])> {
        return flatMap { $0.rx.responseArray(queue: queue, keyPath: keyPath, context: context) }
    }
    public func responseArray<T: ImmutableMappable>(queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil) -> Observable<(HTTPURLResponse, [T])> {
        return flatMap { $0.rx.responseArray(queue: queue, keyPath: keyPath, context: context) }
    }
    public func object<T: BaseMappable>(queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil) -> Observable<T> {
        return flatMap { $0.rx.object(queue: queue, keyPath: keyPath, mapToObject: object, context: context) }
    }
    public func object<T: ImmutableMappable>(queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil) -> Observable<T> {
        return flatMap { $0.rx.object(queue: queue, keyPath: keyPath, mapToObject: object, context: context) }
    }
    public func array<T: BaseMappable>(queue: DispatchQueue? = nil, keyPath: String? = nil, context: MapContext? = nil) -> Observable<[T]> {
        return flatMap { $0.rx.array(queue: queue, keyPath: keyPath, context: context) }
    }
    public func array<T: ImmutableMappable>(queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil) -> Observable<[T]> {
        return flatMap { $0.rx.array(queue: queue, keyPath: keyPath, context: context) }
    }
}

extension Reactive where Base: DataRequest {
    public func responseObject<T: BaseMappable>(queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil) -> Observable<(HTTPURLResponse, T)> {
        return responseResult(queue: queue, responseSerializer: DataRequest.ObjectMapperSerializer(keyPath, mapToObject: object, context: context))
    }
    public func responseObject<T: ImmutableMappable>(queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil) -> Observable<(HTTPURLResponse, T)> {
        return responseResult(queue: queue, responseSerializer: DataRequest.ObjectMapperImmutableSerializer(keyPath, context: context))
    }
    public func responseArray<T: BaseMappable>(queue: DispatchQueue? = nil, keyPath: String? = nil, context: MapContext? = nil) -> Observable<(HTTPURLResponse, [T])> {
        return responseResult(queue: queue, responseSerializer: DataRequest.ObjectMapperArraySerializer(keyPath, context: context))
    }
    public func responseArray<T: ImmutableMappable>(queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil) -> Observable<(HTTPURLResponse, [T])> {
        return responseResult(queue: queue, responseSerializer: DataRequest.ObjectMapperImmutableArraySerializer(keyPath, context: context))
    }
    public func object<T: BaseMappable>(queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil) -> Observable<T> {
        return result(queue: queue, responseSerializer: DataRequest.ObjectMapperSerializer(keyPath, mapToObject: object, context: context))
    }
    public func object<T: ImmutableMappable>(queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil) -> Observable<T> {
        return result(queue: queue, responseSerializer: DataRequest.ObjectMapperImmutableSerializer(keyPath, context: context))
    }
    public func array<T: BaseMappable>(queue: DispatchQueue? = nil, keyPath: String? = nil, context: MapContext? = nil) -> Observable<[T]> {
        return result(queue: queue, responseSerializer: DataRequest.ObjectMapperArraySerializer(keyPath, context: context))
    }
    public func array<T: ImmutableMappable>(queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil) -> Observable<[T]> {
        return result(queue: queue, responseSerializer: DataRequest.ObjectMapperImmutableArraySerializer(keyPath, context: context))
    }
}
