//
//  NSButton+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 5/17/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(macOS)

import RxSwift
import RxCocoa

extension Reactive where Base: NSStepper {
        
    /// Reactive wrapper for `integerValue` property`.
    public var integerValue: ControlProperty<Int> {
        return self.base.rx.controlProperty(
            getter: { control in
                return control.integerValue
            }, setter: { (control: NSStepper, integerValue: Int) in
                control.integerValue = integerValue
            }
        )
    }
}

#endif
