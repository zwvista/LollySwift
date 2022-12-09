//
//  NSStepper+Combine.swift
//  CombineCommon
//
//  Created by 趙偉 on 2022/11/29.
//

import Cocoa
import Combine

extension NSStepper {
    var integerValuePublisher: AnyPublisher<Int, Never> {
        Publishers.ControlProperty(control: self, keyPath: \.integerValue)
            .eraseToAnyPublisher()
    }
    var integerValueProperty: Publishers.ControlProperty2<NSStepper, Int> {
        Publishers.ControlProperty2(control: self, getter: \.integerValuePublisher, setter: \.integerValue)
    }
}
