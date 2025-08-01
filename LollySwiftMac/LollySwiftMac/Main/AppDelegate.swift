//
//  AppDelegate.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import Combine
import AVFAudio

@main
@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {

    let synth = AVSpeechSynthesizer()
    var subscriptions = Set<AnyCancellable>()

    func setup() {
        Task {
            await vmSettings.getData()
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        vmSettings.$initialized.didSet.removeDuplicates().filter { $0 }.sink { [unowned self] v in
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            let wc = storyboard.instantiateController(withIdentifier: "MainWindowController") as! NSWindowController
            wc.showWindow(self)
        } ~ subscriptions

        globalUser.load()
        if globalUser.isLoggedIn {
            setup()
        } else {
            login(self)
        }

        // https://forums.developer.apple.com/thread/69484
        NSSetUncaughtExceptionHandler { exception in
            print(exception)
            print(exception.callStackSymbols)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed() -> Bool {
        true
    }

    @discardableResult
    func showWindow(storyBoardName: String, windowControllerName: String, didLoad: ((NSWindowController) -> Void)? = nil) -> NSWindow {
        let storyboard = NSStoryboard(name: storyBoardName, bundle: nil)
        let wc = storyboard.instantiateController(withIdentifier: windowControllerName) as! NSWindowController
        didLoad?(wc)
        wc.showWindow(self)
        return wc.window!
    }

    @discardableResult
    func findOrShowWindow(storyBoardName: String, windowControllerName: String) -> NSWindow {
        if let w = NSApplication.shared.windows.first(where: { $0.windowController?.className.contains( windowControllerName) ?? false }) {
            // https://stackoverflow.com/questions/29328281/os-x-menubar-application-how-to-bring-window-to-front
            w.makeKeyAndOrderFront(nil)
            return w
        } else {
            return showWindow(storyBoardName: storyBoardName, windowControllerName: windowControllerName)
        }
    }

    @discardableResult
    func runModal(storyBoardName: String, windowControllerName: String) -> NSApplication.ModalResponse {
        let storyboard = NSStoryboard(name: storyBoardName, bundle: nil)
        let wc = storyboard.instantiateController(withIdentifier: windowControllerName) as! NSWindowController
        return NSApplication.shared.runModal(for: wc.window!)
    }

    @IBAction func login(_ sender: AnyObject) {
        NSApplication.shared.enumerateWindows(options: .orderedFrontToBack) { window, stop in
            window.close()
        }
        globalUser.remove()
        vmSettings.initialized = false
        if runModal(storyBoardName: "Main", windowControllerName: "LoginWindowController") == .OK {
            setup()
        } else {
            NSApplication.shared.terminate(self)
        }
    }

    @IBAction func editUnitBlog(_ sender: AnyObject) {
        editPost(item: nil)
    }

    @IBAction func readNumber(_ sender: AnyObject) {
        showWindow(storyBoardName: "Misc", windowControllerName: "ReadNumberWindowController")
    }

    @IBAction func speak(_ sender: AnyObject) {
        let dialogue = AVSpeechUtterance(string: NSPasteboard.general.string(forType: .string) ?? "")
        dialogue.voice = AVSpeechSynthesisVoice(identifier: vmSettings.macVoiceName)
        synth.speak(dialogue)
    }

    func searchWord(word: String) {
        let w = NSApplication.shared.windows.last!
        let v = findOrShowWindow(storyBoardName: "Words", windowControllerName: "WordsSearchWindowController").contentViewController as! WordsSearchViewController
        v.addNewWord(word: word)
        w.makeKeyAndOrderFront(nil)
    }

    func addNewUnitPhrase(wordid: Int) {
        let w = NSApplication.shared.windows.last!
        let v = findOrShowWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesUnitWindowController").contentViewController as! PhrasesUnitViewController
        v.addPhrase(wordid: wordid)
        w.makeKeyAndOrderFront(nil)
    }

    func addNewUnitWord(phraseid: Int) {
        let w = NSApplication.shared.windows.last!
//        wordsInUnit(self)
        let v = findOrShowWindow(storyBoardName: "Words", windowControllerName: "WordsUnitWindowController").contentViewController as! WordsUnitViewController
        v.addWord(phraseid: phraseid)
        w.makeKeyAndOrderFront(nil)
    }

    func editPost(item: MLangBlogPostContent?) {
        showWindow(storyBoardName: "Blogs", windowControllerName: "BlogPostEditWindowController") { @MainActor wc in
            let v = wc.contentViewController as! BlogPostEditViewController
            v.vm = BlogPostEditViewModel(item: item)
        }
    }
}

@MainActor
let vmSettings = SettingsViewModel()
