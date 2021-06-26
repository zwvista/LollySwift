//
//  AppDelegate.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import NSObject_Rx

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    static let theSettingsViewModel = SettingsViewModel()
    let synth = NSSpeechSynthesizer()

    func setup() {
        AppDelegate.theSettingsViewModel.getData().subscribe(onNext: {
            //self.search(self)
            //self.editBlog(self)
            self.wordsInUnit(self)
            //self.wordsInLanguage(self)
            //self.readNumber(self)
            //self.patternsInLanguage(self)
            //self.phrasesInUnit(self)
            //self.wordsReview(self)
        }) ~ rx.disposeBag
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        SettingsViewModel.userid = UserDefaults.standard.string(forKey: "userid") ?? ""
        if SettingsViewModel.userid.isEmpty {
            login(self)
        } else {
            setup()
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
    
    func showWindow(storyBoardName: String, windowControllerName: String) {
        let storyboard = NSStoryboard(name: storyBoardName, bundle: nil)
        let wc = storyboard.instantiateController(withIdentifier: windowControllerName) as! NSWindowController
        wc.showWindow(self)
    }
    
    func findWindow(windowControllerName: String) -> NSWindow? {
        NSApplication.shared.windows.first(where: { $0.windowController?.className.contains( windowControllerName) ?? false })
    }
    
    func findOrShowWindow(storyBoardName: String, windowControllerName: String) -> NSWindow {
        if let w = findWindow(windowControllerName: windowControllerName) {
            // https://stackoverflow.com/questions/29328281/os-x-menubar-application-how-to-bring-window-to-front
            w.makeKeyAndOrderFront(nil)
            return w
        } else {
            showWindow(storyBoardName: storyBoardName, windowControllerName: windowControllerName)
            return findWindow(windowControllerName: windowControllerName)!
        }
    }
    
    func runModal(storyBoardName: String, windowControllerName: String) -> NSApplication.ModalResponse {
        let storyboard = NSStoryboard(name: storyBoardName, bundle: nil)
        let wc = storyboard.instantiateController(withIdentifier: windowControllerName) as! NSWindowController
        return NSApplication.shared.runModal(for: wc.window!)
    }

    @IBAction func login(_ sender: AnyObject) {
        NSApplication.shared.enumerateWindows(options: .orderedFrontToBack) { window, stop in
            window.close()
        }
        UserDefaults.standard.removeObject(forKey: "userid")
        let r = runModal(storyBoardName: "Main", windowControllerName: "LoginWindowController")
        if r == .OK {
            setup()
        } else {
            NSApplication.shared.terminate(self)
        }
    }

    @IBAction func search(_ sender: AnyObject) {
        _ = findOrShowWindow(storyBoardName: "Words", windowControllerName: "WordsSearchWindowController")
    }

    @IBAction func settings(_ sender: AnyObject) {
        _ = runModal(storyBoardName: "Main", windowControllerName: "SettingsWindowController")
    }
    
    @IBAction func wordsInUnit(_ sender: AnyObject) {
        _ = findOrShowWindow(storyBoardName: "Words", windowControllerName: "WordsUnitWindowController")
    }
    
    @IBAction func wordsInUnitNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Words", windowControllerName: "WordsUnitWindowController")
    }

    @IBAction func phrasesInUnit(_ sender: AnyObject) {
        _ = findOrShowWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesUnitWindowController")
    }

    @IBAction func phrasesInUnitNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesUnitWindowController")
    }
    
    @IBAction func wordsReview(_ sender: AnyObject) {
        _ = findOrShowWindow(storyBoardName: "Words", windowControllerName: "WordsReviewWindowController")
    }
    
    @IBAction func wordsReviewNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Words", windowControllerName: "WordsReviewWindowController")
    }

    @IBAction func phrasesReview(_ sender: AnyObject) {
        _ = findOrShowWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesReviewWindowController")
    }

    @IBAction func phrasesReviewNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesReviewWindowController")
    }

    @IBAction func wordsInTextbook(_ sender: AnyObject) {
        _ = findOrShowWindow(storyBoardName: "Words", windowControllerName: "WordsTextbookWindowController")
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
        _ = findOrShowWindow(storyBoardName: "Words", windowControllerName: "WordsLangWindowController")
    }

    @IBAction func wordsInLanguageNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Words", windowControllerName: "WordsLangWindowController")
    }

    @IBAction func phrasesInLanguage(_ sender: AnyObject) {
        _ = findOrShowWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesLangWindowController")
    }

    @IBAction func phrasesInLanguageNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesLangWindowController")
    }
    
    @IBAction func patternsInLanguage(_ sender: AnyObject) {
        _ = findOrShowWindow(storyBoardName: "Patterns", windowControllerName: "PatternsWindowController")
    }
    
    @IBAction func patternsInLanguageNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Patterns", windowControllerName: "PatternsWindowController")
    }

    @IBAction func editBlog(_ sender: AnyObject) {
        showWindow(storyBoardName: "Misc", windowControllerName: "BlogWindowController")
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
}
