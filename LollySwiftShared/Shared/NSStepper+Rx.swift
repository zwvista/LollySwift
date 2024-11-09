//
//  NSStepper+Rx.swift
//  RxCocoa
//
//  Created by 趙偉 on 2020/08/10.
//  Copyright © 2018 趙偉. All rights reserved.
//

#if os(macOS)

import RxSwift
import RxCocoa

@MainActor
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
