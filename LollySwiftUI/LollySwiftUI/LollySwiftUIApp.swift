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
// https://stackoverflow.com/questions/45998220/the-font-looks-like-smaller-in-wkwebview-than-in-uiwebview
let headString = "<head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></head>"

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
