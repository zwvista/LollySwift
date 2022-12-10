//
//  UIButton+Combine2.swift
//  CombineCommon
//
//  Created by 趙偉 on 2022/12/01.
//

import Combine
import UIKit

extension UIButton {
    var titleNormal: String {
        get { title(for: .normal) ?? "" }
        set { setTitle(newValue, for: .normal) }
    }
}
