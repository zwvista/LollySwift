//
//  NSSegmentedControl+Rx.swift
//  RxCocoa
//
//  Created by 趙偉 on 2020/08/10.
//  Copyright © 2018 趙偉. All rights reserved.
//

#if os(macOS)

import RxSwift
import RxCocoa

extension Reactive where Base: NSSegmentedControl {
        
    /// Reactive wrapper for `isOn` property`.
    public var isOn: ControlProperty<Bool> {
        return self.base.rx.controlProperty(
            getter: { control in
                return control.selectedSegment == 1
            }, setter: { (control: NSSegmentedControl, isOn: Bool) in
                control.selectedSegment = isOn ? 1 : 0
            }
        )
    }
}

#endif
