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
        let selector = #selector(NSTextViewDelegate.textDidChange(_:))
        return delegateProxy
            .interceptSelectorPublisher(selector)
            .map { (($0[0] as! Notification).object as! NSTextView).string }
            .eraseToAnyPublisher()
    }
    var textProperty: Publishers.ControlProperty2<NSTextView, String> {
        Publishers.ControlProperty2(control: self, getter: \.textPublisher, setter: \.string)
    }

    private var delegateProxy: NSTextViewDelegateProxy {
        .createDelegateProxy(for: self)
    }
}

private class NSTextViewDelegateProxy: DelegateProxy, NSTextViewDelegate, DelegateProxyType {
    func setDelegate(to object: NSTextView) {
        object.delegate = self
    }
}
