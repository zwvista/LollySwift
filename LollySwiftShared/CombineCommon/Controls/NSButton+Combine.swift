//
//  NSTextField+Combine.swift
//  CombineCommon
//
//  Created by 趙偉 on 2022/11/29.
//

import Cocoa
import Combine

extension NSButton {
    var tapPublisher: AnyPublisher<Void, Never> {
        Publishers.ControlTarget(control: self,
                                 addTargetAction: { control, target, action in
            control.target = target
            control.action = action
        },
                                 removeTargetAction: { control, _, _ in
            control?.target = nil
            control?.action = nil
        })
        .eraseToAnyPublisher()
    }
    
    @objc var isOn: Bool {
        get {
            state == .on
        }
        set {
            state = newValue ? .on : .off
        }
    }
    var isOnPublisher: AnyPublisher<Bool, Never> {
        Publishers.ControlProperty(control: self, keyPath: \.isOn)
            .eraseToAnyPublisher()
    }
    var isOnProperty: Publishers.ControlProperty2<NSButton, Bool> {
        Publishers.ControlProperty2(control: self, getter: \.isOnPublisher, setter: \.isOn)
    }
}
