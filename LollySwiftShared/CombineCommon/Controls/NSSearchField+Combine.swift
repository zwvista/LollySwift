//
//  NSTextField+Combine.swift
//  CombineCommon
//
//  Created by 趙偉 on 2022/11/29.
//

import Cocoa
import Combine

extension NSSearchField {
    /// Combine wrapper for `NSSearchFieldDelegate.searchFieldDidStartSearching(_:)`
    var didStartSearchingPublisher: AnyPublisher<Void, Never> {
        let selector = #selector(NSSearchFieldDelegate.searchFieldDidStartSearching(_:))
        return delegateProxy
            .interceptSelectorPublisher(selector)
            .map { _ in }
            .eraseToAnyPublisher()
    }

    /// Combine wrapper for `NSSearchFieldDelegate.searchFieldDidStartSearching(_:)`
    var didEndSearchingPublisher: AnyPublisher<Void, Never> {
        let selector = #selector(NSSearchFieldDelegate.searchFieldDidEndSearching(_:))
        return delegateProxy
            .interceptSelectorPublisher(selector)
            .map { _ in }
            .eraseToAnyPublisher()
    }

    private var delegateProxy: NSSearchFieldDelegateProxy {
        .createDelegateProxy(for: self)
    }
}

private class NSSearchFieldDelegateProxy: DelegateProxy, NSSearchFieldDelegate, DelegateProxyType {
    func setDelegate(to object: NSSearchField) {
        object.delegate = self
    }
}
