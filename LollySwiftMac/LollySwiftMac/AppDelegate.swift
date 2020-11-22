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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        AppDelegate.theSettingsViewModel.getData().subscribe(onNext: {
            //self.search(self)
            //self.editBlog(self)
            self.wordsInUnit(self)
            //self.wordsInLanguage(self)
            //self.readNumber(self)
            //self.patternsInLanguage(self)
            //self.phrasesInUnit(self)
        }) ~ rx.disposeBag

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
    
    func showWindow(storyBoardName: String, windowControllerName: String, modal: Bool) {
        let storyboard = NSStoryboard(name: storyBoardName, bundle: nil)
        let wc = storyboard.instantiateController(withIdentifier: windowControllerName) as! NSWindowController
        if modal {
            NSApplication.shared.runModal(for: wc.window!)
        } else {
            wc.showWindow(self)
        }
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
            showWindow(storyBoardName: storyBoardName, windowControllerName: windowControllerName, modal: false)
            return findWindow(windowControllerName: windowControllerName)!
        }
    }
    
    @IBAction func search(_ sender: AnyObject) {
        _ = findOrShowWindow(storyBoardName: "Words", windowControllerName: "WordsSearchWindowController")
    }

    @IBAction func settings(_ sender: AnyObject) {
        showWindow(storyBoardName: "Main", windowControllerName: "SettingsWindowController", modal: true)
    }
    
    @IBAction func wordsInUnit(_ sender: AnyObject) {
        _ = findOrShowWindow(storyBoardName: "Words", windowControllerName: "WordsUnitWindowController")
    }
    
    @IBAction func wordsInUnitNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Words", windowControllerName: "WordsUnitWindowController", modal: false)
    }

    @IBAction func phrasesInUnit(_ sender: AnyObject) {
        _ = findOrShowWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesUnitWindowController")
    }

    @IBAction func phrasesInUnitNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesUnitWindowController", modal: false)
    }
    
    @IBAction func wordsReview(_ sender: AnyObject) {
        _ = findOrShowWindow(storyBoardName: "Words", windowControllerName: "WordsReviewWindowController")
    }
    
    @IBAction func wordsReviewNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Words", windowControllerName: "WordsReviewWindowController", modal: false)
    }

    @IBAction func phrasesReview(_ sender: AnyObject) {
        _ = findOrShowWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesReviewWindowController")
    }

    @IBAction func phrasesReviewNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesReviewWindowController", modal: false)
    }

    @IBAction func wordsInTextbook(_ sender: AnyObject) {
        _ = findOrShowWindow(storyBoardName: "Words", windowControllerName: "WordsTextbookWindowController")
    }
    
    @IBAction func wordsInTextbookNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Words", windowControllerName: "WordsTextbookWindowController", modal: false)
    }
    
    @IBAction func phrasesInTextbook(_ sender: AnyObject) {
        showWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesTextbookWindowController", modal: false)
    }
    
    @IBAction func phrasesInTextbookNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesTextbookWindowController", modal: false)
    }

    @IBAction func wordsInLanguage(_ sender: AnyObject) {
        _ = findOrShowWindow(storyBoardName: "Words", windowControllerName: "WordsLangWindowController")
    }

    @IBAction func wordsInLanguageNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Words", windowControllerName: "WordsLangWindowController", modal: false)
    }

    @IBAction func phrasesInLanguage(_ sender: AnyObject) {
        _ = findOrShowWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesLangWindowController")
    }

    @IBAction func phrasesInLanguageNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesLangWindowController", modal: false)
    }
    
    @IBAction func patternsInLanguage(_ sender: AnyObject) {
        _ = findOrShowWindow(storyBoardName: "Patterns", windowControllerName: "PatternsWindowController")
    }
    
    @IBAction func patternsInLanguageNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Patterns", windowControllerName: "PatternsWindowController", modal: false)
    }

    @IBAction func editBlog(_ sender: AnyObject) {
        showWindow(storyBoardName: "Misc", windowControllerName: "BlogWindowController", modal: false)
    }
    
    @IBAction func textbooks(_ sender: AnyObject) {
        showWindow(storyBoardName: "Textbooks", windowControllerName: "TextbooksWindowController", modal: false)
    }
    
    @IBAction func webtextbooks(_ sender: AnyObject) {
        showWindow(storyBoardName: "Textbooks", windowControllerName: "WebTextbooksWindowController", modal: false)
    }

    @IBAction func dictionaries(_ sender: AnyObject) {
        showWindow(storyBoardName: "Dicts", windowControllerName: "DictsWindowController", modal: false)
    }
    
    @IBAction func readNumber(_ sender: AnyObject) {
        showWindow(storyBoardName: "Misc", windowControllerName: "ReadNumberWindowController", modal: false)
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
        let v = findOrShowWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesUnitViewController").contentViewController as! PhrasesUnitViewController
        v.addPhrase(wordid: wordid)
        w.makeKeyAndOrderFront(nil)
    }
    
    func addNewUnitWord(phraseid: Int) {
        let w = NSApplication.shared.windows.last!
        wordsInUnit(self)
        let v = findOrShowWindow(storyBoardName: "Words", windowControllerName: "WordsUnitViewController").contentViewController as! WordsUnitViewController
        v.addWord(phraseid: phraseid)
        w.makeKeyAndOrderFront(nil)
    }
}
