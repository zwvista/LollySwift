//
//  Publisher+UITextField.swift
//  CombineBind
//
//  Created by 趙偉 on 2022/12/01.
//

import UIKit
import Combine
import CombineCocoa

infix operator <~> : DefaultPrecedence

extension Published<String>.Publisher {
    mutating func twoWayBind(textField: UITextField) -> AnyCancellable {
        textField.textPublisher.compactMap{$0}.assign(to: &self)
        return self.assign(to: \UITextField.text!, on: textField)
    }
    public static func <~> (pub: inout Published<String>.Publisher, textField: UITextField) -> AnyCancellable {
        pub.twoWayBind(textField: textField)
    }
}
