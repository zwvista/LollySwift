//
//  WebPageSelectViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/23.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import Combine

class WebPageSelectViewModel: NSObject, ObservableObject {
    @Published var title = ""
    @Published var url = ""
    var vmSettings: SettingsViewModel
    var arrWebPages = [MWebPage]()
    var selectedWebPage: MWebPage?

    var subscriptions = Set<AnyCancellable>()

    init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        vmSettings = settings
        super.init()
        Task {
            await reload(t: "", u: "")
            complete()
        }
        $title.debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .combineLatest($url.debounce(for: .milliseconds(500), scheduler: DispatchQueue.main))
            .sink { [unowned self] (t, u) in
                Task {
                    await reload(t: t, u: u)
                    complete()
                }
            } ~ subscriptions
    }

    func reload(t: String, u: String) async {
        arrWebPages = await MWebPage.getDataBySearch(title: t, url: u)
    }
}
