//
//  NSTextField+Combine.swift
//  CombineCommon
//
//  Created by 趙偉 on 2022/11/29.
//

import Cocoa
import Combine

extension NSTextView {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: NSControl.textDidChangeNotification, object: self)
            .map { ($0.object as! NSTextView).string }
            .eraseToAnyPublisher()
    }
    var textProperty: Publishers.ControlProperty2<NSTextView, String> {
        Publishers.ControlProperty2(control: self, getter: \.textPublisher, setter: \.string)
    }
}
