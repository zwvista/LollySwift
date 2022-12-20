//
//  LollySwiftUIMacApp.swift
//  LollySwiftUIMac
//
//  Created by 趙偉 on 2020/11/30.
//

import SwiftUI

@main
struct LollySwiftUIMacApp: App {

    static let theSettingsViewModel = SettingsViewModel()
    let synth = NSSpeechSynthesizer()
    let disposeBag = DisposeBag()

    init() {
        LollySwiftUIMacApp.theSettingsViewModel.getData().subscribe(onNext: {
        }) ~ disposeBag
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
