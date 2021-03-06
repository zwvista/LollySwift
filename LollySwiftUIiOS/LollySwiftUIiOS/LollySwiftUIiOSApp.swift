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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    private static let synth = AVSpeechSynthesizer()
    
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

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        globalUser.userid = UserDefaults.standard.string(forKey: "userid") ?? ""
        return true
    }
}
