//
//  NSTextField+Combine.swift
//  CombineCommon
//
//  Created by 趙偉 on 2022/11/29.
//

import Cocoa
import Combine

extension NSPopUpButton {
    @objc var selectedItemIndex: Int {
        get {
            indexOfSelectedItem
        }
        set {
            selectItem(at: newValue)
        }
    }
    var selectedItemIndexPublisher: AnyPublisher<Int, Never> {
        Publishers.ControlProperty(control: self, keyPath: \.selectedItemIndex)
            .eraseToAnyPublisher()
    }
    var selectedItemIndexProperty: Publishers.ControlProperty2<NSPopUpButton, Int> {
        Publishers.ControlProperty2(control: self, getter: \.selectedItemIndexPublisher, setter: \.selectedItemIndex)
    }
}
