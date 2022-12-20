//
//  NSSearchField+Rx.swift
//  RxCocoa
//

#if os(macOS)

import RxSwift
import RxCocoa

extension Reactive where Base: NSSearchField {

    public var searchFieldDidStartSearching: ControlEvent<()> {
        let source = delegate.methodInvoked(#selector(NSSearchFieldDelegate.searchFieldDidStartSearching(_:))).map {_ in }
        return ControlEvent(events: source)
    }

    public var searchFieldDidEndSearching: ControlEvent<()> {
        let source = delegate.methodInvoked(#selector(NSSearchFieldDelegate.searchFieldDidEndSearching(_:))).map {_ in }
        return ControlEvent(events: source)
    }
}

#endif
