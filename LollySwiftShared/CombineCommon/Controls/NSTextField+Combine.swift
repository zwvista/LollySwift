//
//  NSTextField+Combine.swift
//  CombineCommon
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

    var controlTextDidEndEditingPublisher: AnyPublisher<Void, Never> {
        let selector = #selector(NSTextFieldDelegate.controlTextDidEndEditing(_:))
        return delegateProxy
            .interceptSelectorPublisher(selector)
            .map { _ in }
            .eraseToAnyPublisher()
    }

    private var delegateProxy: NSTextFieldDelegateProxy {
        .createDelegateProxy(for: self)
    }
}

private class NSTextFieldDelegateProxy: DelegateProxy, NSTextFieldDelegate, DelegateProxyType {
    func setDelegate(to object: NSTextField) {
        object.delegate = self
    }
}
