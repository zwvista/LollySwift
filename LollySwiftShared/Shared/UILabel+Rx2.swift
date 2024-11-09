//
//  UILabel+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/1/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(visionOS)

import RxSwift
import UIKit

@MainActor
extension Reactive where Base: UILabel {

    /// Bindable sink for `enabled` property.
    public var isEnabled: Binder<Bool>  {
        Binder(self.base) { owner, value in
            owner.isEnabled = value
        }
    }
}

#endif
