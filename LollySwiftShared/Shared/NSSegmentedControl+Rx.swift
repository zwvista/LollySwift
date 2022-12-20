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
                control.selectedSegment == 1
            }, setter: { (control: NSSegmentedControl, isOn: Bool) in
                control.selectedSegment = isOn ? 1 : 0
            }
        )
    }

    /// Reactive wrapper for `selectedSegment` property`.
    public var selectedSegment: ControlProperty<Int> {
        return self.base.rx.controlProperty(
            getter: { control in
                control.selectedSegment
            }, setter: { (control: NSSegmentedControl, selectedSegment: Int) in
                control.selectedSegment = selectedSegment
            }
        )
    }

    /// Reactive wrapper for `selectedLabel` property`.
    public var selectedLabel: ControlProperty<String> {
        return self.base.rx.controlProperty(
            getter: { control in
                control.label(forSegment: control.selectedSegment)!
            }, setter: { (control: NSSegmentedControl, selectedLabel: String) in
                control.selectedSegment = (0..<control.segmentCount).first { control.label(forSegment: $0) == selectedLabel } ?? 0
            }
        )
    }
}

#endif
