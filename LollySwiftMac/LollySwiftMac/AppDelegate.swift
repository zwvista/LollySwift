//
//  AppDelegate.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import RxBinding

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    static let theSettingsViewModel = SettingsViewModel()
    let synth = NSSpeechSynthesizer()

    func setup() {
        AppDelegate.theSettingsViewModel.getData().subscribe() ~ rx.disposeBag
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        AppDelegate.theSettingsViewModel.initialized.distinctUntilChanged().filter { $0 }.subscribe { [unowned self] v in
            //search(self)
            //editPost(self)
            wordsInUnit(self)
            //wordsInLanguage(self)
            //readNumber(self)
            //patternsInLanguage(self)
            //phrasesInUnit(self)
            //wordsReview(self)
        } ~ rx.disposeBag

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
        AppDelegate.theSettingsViewModel.initialized.accept(false)
        if runModal(storyBoardName: "Main", windowControllerName: "LoginWindowController") == .OK {
            setup()
        } else {
            NSApplication.shared.terminate(self)
        }
    }

    @IBAction func search(_ sender: AnyObject) {
        findOrShowWindow(storyBoardName: "Words", windowControllerName: "WordsSearchWindowController")
    }

    @IBAction func settings(_ sender: AnyObject) {
        runModal(storyBoardName: "Main", windowControllerName: "SettingsWindowController")
    }

    @IBAction func wordsInUnit(_ sender: AnyObject) {
        findOrShowWindow(storyBoardName: "Words", windowControllerName: "WordsUnitWindowController")
    }

    @IBAction func wordsInUnitNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Words", windowControllerName: "WordsUnitWindowController")
    }

    @IBAction func phrasesInUnit(_ sender: AnyObject) {
        findOrShowWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesUnitWindowController")
    }

    @IBAction func phrasesInUnitNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesUnitWindowController")
    }

    @IBAction func wordsReview(_ sender: AnyObject) {
        findOrShowWindow(storyBoardName: "Words", windowControllerName: "WordsReviewWindowController")
    }

    @IBAction func wordsReviewNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Words", windowControllerName: "WordsReviewWindowController")
    }

    @IBAction func phrasesReview(_ sender: AnyObject) {
        findOrShowWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesReviewWindowController")
    }

    @IBAction func phrasesReviewNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesReviewWindowController")
    }

    @IBAction func wordsInTextbook(_ sender: AnyObject) {
        findOrShowWindow(storyBoardName: "Words", windowControllerName: "WordsTextbookWindowController")
    }

    @IBAction func wordsInTextbookNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Words", windowControllerName: "WordsTextbookWindowController")
    }

    @IBAction func phrasesInTextbook(_ sender: AnyObject) {
        showWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesTextbookWindowController")
    }

    @IBAction func phrasesInTextbookNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesTextbookWindowController")
    }

    @IBAction func wordsInLanguage(_ sender: AnyObject) {
        findOrShowWindow(storyBoardName: "Words", windowControllerName: "WordsLangWindowController")
    }

    @IBAction func wordsInLanguageNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Words", windowControllerName: "WordsLangWindowController")
    }

    @IBAction func phrasesInLanguage(_ sender: AnyObject) {
        findOrShowWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesLangWindowController")
    }

    @IBAction func phrasesInLanguageNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesLangWindowController")
    }

    @IBAction func patternsInLanguage(_ sender: AnyObject) {
        findOrShowWindow(storyBoardName: "Patterns", windowControllerName: "PatternsWindowController")
    }

    @IBAction func patternsInLanguageNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Patterns", windowControllerName: "PatternsWindowController")
    }

    @IBAction func editUnitBlog(_ sender: AnyObject) {
        editPost(settings: AppDelegate.theSettingsViewModel, item: nil)
    }

    @IBAction func showLangBlogGroups(_ sender: AnyObject) {
        showWindow(storyBoardName: "Blogs", windowControllerName: "LangBlogGroupsWindowController")
    }

    @IBAction func showLangBlogPosts(_ sender: AnyObject) {
        showWindow(storyBoardName: "Blogs", windowControllerName: "LangBlogPostsWindowController")
    }

    @IBAction func textbooks(_ sender: AnyObject) {
        showWindow(storyBoardName: "Textbooks", windowControllerName: "TextbooksWindowController")
    }

    @IBAction func webtextbooks(_ sender: AnyObject) {
        showWindow(storyBoardName: "Textbooks", windowControllerName: "WebTextbooksWindowController")
    }

    @IBAction func dictionaries(_ sender: AnyObject) {
        showWindow(storyBoardName: "Dicts", windowControllerName: "DictsWindowController")
    }

    @IBAction func readNumber(_ sender: AnyObject) {
        showWindow(storyBoardName: "Misc", windowControllerName: "ReadNumberWindowController")
    }

    @IBAction func speak(_ sender: AnyObject) {
        synth.setVoice(NSSpeechSynthesizer.VoiceName(rawValue: AppDelegate.theSettingsViewModel.macVoiceName))
        let s = NSPasteboard.general.string(forType: .string) ?? ""
        synth.startSpeaking(s)
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
        wordsInUnit(self)
        let v = findOrShowWindow(storyBoardName: "Words", windowControllerName: "WordsUnitWindowController").contentViewController as! WordsUnitViewController
        v.addWord(phraseid: phraseid)
        w.makeKeyAndOrderFront(nil)
    }

    func editPost(settings: SettingsViewModel, item: MLangBlogPostContent?) {
        showWindow(storyBoardName: "Blogs", windowControllerName: "BlogPostEditWindowController") { wc in
            let v = wc.contentViewController as! BlogPostEditViewController
            v.vm = BlogPostEditViewModel(settings: settings, item: item)
        }
    }
}
