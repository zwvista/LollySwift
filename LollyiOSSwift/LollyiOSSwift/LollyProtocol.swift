//
//  LollyExtension.swift
//  LollyiOSSwift
//
//  Created by 趙偉 on 2016/08/22.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

protocol LollyProtocol {
    var vmSettings: SettingsViewModel { get }
}

extension LollyProtocol {
    var vmSettings: SettingsViewModel {
        return AppDelegate.theSettingsViewModel
    }

}