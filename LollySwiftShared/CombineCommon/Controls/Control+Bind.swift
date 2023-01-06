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
    let (control, setter, getter) = (controlProperty.control, controlProperty.setter, controlProperty.getter)
    let _ = pub.first().sink { control[keyPath: setter] = $0 }
    let cancellable = pub.didSet.assign(to: setter, on: control)
    control[keyPath: getter].assign(to: &pub)
    return cancellable
}

func ~><Control: AnyObject, Value> (pub: Published<Value>.Publisher, controlAndKeyPath: (Control, ReferenceWritableKeyPath<Control, Value>)) -> AnyCancellable {
    let (control, setter) = (controlAndKeyPath.0, controlAndKeyPath.1)
    let _ = pub.first().sink { control[keyPath: setter] = $0 }
    return pub.didSet.assign(to: setter, on: control)
}
func ~><Control: AnyObject, Value> (pub: AnyPublisher<Value, Never>, controlAndKeyPath: (Control, ReferenceWritableKeyPath<Control, Value>)) -> AnyCancellable {
    let (control, setter) = (controlAndKeyPath.0, controlAndKeyPath.1)
    let _ = pub.first().sink { control[keyPath: setter] = $0 }
    return pub.receive(on: DispatchQueue.main).assign(to: setter, on: control)
}
