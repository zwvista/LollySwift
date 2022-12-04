//
//  CombineControlProperty2.swift
//  CombineMacExample
//
//  Created by 趙偉 on 2022/12/04.
//

import Foundation
import Combine

extension Combine.Publishers {
    struct ControlProperty2<Control: AnyObject, Value> {
        let control: Control
        let getter: KeyPath<Control, AnyPublisher<Value, Never>>
        let setter: ReferenceWritableKeyPath<Control, Value>
    }
}
