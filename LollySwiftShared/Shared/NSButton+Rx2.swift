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

extension Reactive where Base: NSButton {
        
    /// Reactive wrapper for `title` property`.
    public var title: ControlProperty<String> {
        return self.base.rx.controlProperty(
            getter: { control in
                return control.title
            }, setter: { (control: NSButton, title: String) in
                control.title = title
            }
        )
    }
}

#endif
