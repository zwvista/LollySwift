//
//  NSTextField+Combine.swift
//  CombineMacExample
//
//  Created by 趙偉 on 2022/11/29.
//

import Combine
import AppKit

extension NSTextField {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: NSControl.textDidChangeNotification, object: self)
            .map { ($0.object as! NSTextField).stringValue }
            .eraseToAnyPublisher()
    }
}
