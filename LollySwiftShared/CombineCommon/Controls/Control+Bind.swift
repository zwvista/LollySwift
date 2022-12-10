//
//  Control+Bind.swift
//  CombineCommon
//
//  Created by 趙偉 on 2022/12/01.
//

import Foundation
import Combine

infix operator <~> : DefaultPrecedence

func <~><Control: AnyObject, Value> (pub: inout Published<Value>.Publisher, controlProperty: Publishers.ControlProperty2<Control, Value>) -> AnyCancellable {
    let cancellable = pub.assign(to: controlProperty.setter, on: controlProperty.control)
    controlProperty.control[keyPath: controlProperty.getter].assign(to: &pub)
    return cancellable
}

func ~><Control: AnyObject, Value> (pub: Published<Value>.Publisher, controlAndKeyPath: (Control, ReferenceWritableKeyPath<Control, Value>)) -> AnyCancellable {
    pub.assign(to: controlAndKeyPath.1, on: controlAndKeyPath.0)
}
func ~><Control: AnyObject, Value> (pub: AnyPublisher<Value, Never>, controlAndKeyPath: (Control, ReferenceWritableKeyPath<Control, Value>)) -> AnyCancellable {
    pub.assign(to: controlAndKeyPath.1, on: controlAndKeyPath.0)
}
