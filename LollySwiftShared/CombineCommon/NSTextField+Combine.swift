//
//  NSTextField+Combine.swift
//  CombineMacExample
//
//  Created by 趙偉 on 2022/11/29.
//

import Cocoa
import Combine

extension NSTextField {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: NSControl.textDidChangeNotification, object: self)
            .map { ($0.object as! NSTextField).stringValue }
            .eraseToAnyPublisher()
    }
    var textProperty: Publishers.ControlProperty2<NSTextField, String> {
        Publishers.ControlProperty2(control: self, getter: \.textPublisher, setter: \.stringValue)
    }
}
