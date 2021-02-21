//
//  NSTextField+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 5/17/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(macOS)

import RxSwift
import RxCocoa

extension Reactive where Base: NSTextField {

    public var controlTextDidEndEditing: ControlEvent<()> {
        let source = delegate.methodInvoked(#selector(NSTextFieldDelegate.controlTextDidEndEditing(_:))).map {_ in }
        return ControlEvent(events: source)
    }
}

#endif
