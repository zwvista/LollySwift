//
//  LollySwiftUIiOSApp.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2020/11/30.
//

import SwiftUI
import RxSwift
import AVFoundation

@main
struct LollySwiftUIiOSApp: App {
    private static let synth = AVSpeechSynthesizer()
    private static let _initializeObject = ReplaySubject<()>.create(bufferSize: 1)
    static var initializeObject: ReplaySubject<()> { _initializeObject }
    let disposeBag = DisposeBag()
    
    init() {
        vmSettings.getData().subscribe(onNext: {
            LollySwiftUIiOSApp._initializeObject.onNext(())
            LollySwiftUIiOSApp._initializeObject.onCompleted()
        }) ~ disposeBag
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    static func speak(string: String) {
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(identifier: vmSettings.selectediOSVoice.VOICENAME)
        LollySwiftUIiOSApp.synth.speak(utterance)
    }
}

var vmSettings = SettingsViewModel()
