//
//  UISwitch+Combine2.swift
//  CombineCommon
//
//  Created by 趙偉 on 2022/12/01.
//

import Combine
import UIKit
import CombineCocoa

extension UISwitch {
    var isOnPublisher: AnyPublisher<Bool, Never> {
        Publishers.ControlProperty(control: self, events: [.allEditingEvents, .valueChanged], keyPath: \.isOn)
                  .eraseToAnyPublisher()
    }
    var isOnProperty: Publishers.ControlProperty2<UISwitch, Bool> {
        Publishers.ControlProperty2(control: self, getter: \.isOnPublisher, setter: \.isOn)
    }
}
