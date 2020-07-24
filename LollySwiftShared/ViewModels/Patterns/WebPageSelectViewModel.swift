//
//  WebPageSelectViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/23.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class WebPageSelectViewModel: NSObject {
    @objc var title = ""
    @objc var url = ""
    var vmSettings: SettingsViewModel
    var arrWebPages = [MWebPage]()
    var selectedWebPage: MWebPage?
    
    public init(settings: SettingsViewModel, complete: @escaping () -> ()) {
        self.vmSettings = settings
        super.init()
        reload().subscribe { complete() } ~ rx.disposeBag
    }
    
    func reload() -> Observable<()> {
        MWebPage.getDataBySearch(title: title, url: url).map {
            self.arrWebPages = $0
        }
    }

}
