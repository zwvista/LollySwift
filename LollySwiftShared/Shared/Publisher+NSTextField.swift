//
//  Publisher+NSTextField.swift
//  CombineMacExample
//
//  Created by 趙偉 on 2022/12/01.
//

import AppKit
import Combine

infix operator <~> : DefaultPrecedence
infix operator ~> : DefaultPrecedence

extension Published<String>.Publisher {
    mutating func twoWayBind(textField: NSTextField) -> AnyCancellable {
        textField.textPublisher.assign(to: &self)
        return self.assign(to: \.stringValue, on: textField)
    }
    public static func <~> (pub: inout Published<String>.Publisher, textField: NSTextField) -> AnyCancellable {
        pub.twoWayBind(textField: textField)
    }
    func oneWayBind(textField: NSTextField) -> AnyCancellable {
        self.assign(to: \.stringValue, on: textField)
    }
    public static func ~> (pub: Published<String>.Publisher, textField: NSTextField) -> AnyCancellable {
        pub.oneWayBind(textField: textField)
    }
}
