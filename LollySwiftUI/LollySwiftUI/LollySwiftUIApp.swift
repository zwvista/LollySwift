//
//  LollySwiftUIApp.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2020/11/30.
//

import SwiftUI
import AVFoundation

@main
struct LollySwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var webViewStore = WebViewStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(webViewStore)
        }
    }
}

@MainActor
let vmSettings = SettingsViewModel()

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        globalUser.load()
        return true
    }

    private static let synth = AVSpeechSynthesizer()
    static func speak(string: String) {
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(identifier: vmSettings.selectediOSVoice.VOICENAME)
        synth.speak(utterance)
    }
}

extension Color {
    static let color1 = Color("Color1")
    static let color2 = Color("Color2")
    static let color3 = Color("Color3")
}
