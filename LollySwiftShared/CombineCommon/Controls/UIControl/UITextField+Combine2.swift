//
//  UITextField+Combine2.swift
//  CombineCommon
//
//  Created by 趙偉 on 2022/12/01.
//

import Combine
import UIKit

extension UITextField {
    var text2: String {
        get { text ?? "" }
        set { text = newValue }
    }
    var text2Publisher: AnyPublisher<String, Never> {
        textPublisher.compactMap { $0 }.eraseToAnyPublisher()
    }
    var textProperty: Publishers.ControlProperty2<UITextField, String> {
        Publishers.ControlProperty2(control: self, getter: \.text2Publisher, setter: \.text2)
    }
}
