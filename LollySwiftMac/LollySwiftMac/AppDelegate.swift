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
    
    func findOrShowWindow(storyBoardName: String, windowControllerName: String) {
        if let w = NSApplication.shared.windows.first(where: { $0.windowController?.className.contains( windowControllerName) ?? false }) {
            // https://stackoverflow.com/questions/29328281/os-x-menubar-application-how-to-bring-window-to-front
            w.makeKeyAndOrderFront(nil)
        } else {
            showWindow(storyBoardName: storyBoardName, windowControllerName: windowControllerName, modal: false)
        }
    }
    
    @IBAction func search(_ sender: AnyObject) {
        showWindow(storyBoardName: "Words", windowControllerName: "WordsSearchWindowController", modal: false)
    }

    @IBAction func settings(_ sender: AnyObject) {
        showWindow(storyBoardName: "Main", windowControllerName: "SettingsWindowController", modal: true)
    }
    
    @IBAction func wordsInUnit(_ sender: AnyObject) {
        findOrShowWindow(storyBoardName: "Words", windowControllerName: "WordsUnitWindowController")
    }
    
    @IBAction func wordsInUnitNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Words", windowControllerName: "WordsUnitWindowController", modal: false)
    }

    @IBAction func phrasesInUnit(_ sender: AnyObject) {
        findOrShowWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesUnitWindowController")
    }

    @IBAction func phrasesInUnitNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesUnitWindowController", modal: false)
    }
    
    @IBAction func wordsReview(_ sender: AnyObject) {
        findOrShowWindow(storyBoardName: "Words", windowControllerName: "WordsReviewWindowController")
    }
    
    @IBAction func wordsReviewNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Words", windowControllerName: "WordsReviewWindowController", modal: false)
    }

    @IBAction func phrasesReview(_ sender: AnyObject) {
        findOrShowWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesReviewWindowController")
    }

    @IBAction func phrasesReviewNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesReviewWindowController", modal: false)
    }

    @IBAction func wordsInTextbook(_ sender: AnyObject) {
        findOrShowWindow(storyBoardName: "Words", windowControllerName: "WordsTextbookWindowController")
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
        findOrShowWindow(storyBoardName: "Words", windowControllerName: "WordsLangWindowController")
    }

    @IBAction func wordsInLanguageNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Words", windowControllerName: "WordsLangWindowController", modal: false)
    }

    @IBAction func phrasesInLanguage(_ sender: AnyObject) {
        findOrShowWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesLangWindowController")
    }

    @IBAction func phrasesInLanguageNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesLangWindowController", modal: false)
    }
    
    @IBAction func patternsInLanguage(_ sender: AnyObject) {
        findOrShowWindow(storyBoardName: "Patterns", windowControllerName: "PatternsWindowController")
    }
    
    @IBAction func patternsInLanguageNew(_ sender: AnyObject) {
        showWindow(storyBoardName: "Patterns", windowControllerName: "PatternsWindowController", modal: false)
    }

    @IBAction func editBlog(_ sender: AnyObject) {
        showWindow(storyBoardName: "Misc", windowControllerName: "BlogWindowController", modal: false)
    }
    
    @IBAction func textbooks(_ sender: AnyObject) {
        showWindow(storyBoardName: "Misc", windowControllerName: "TextbooksWindowController", modal: false)
    }
    
    @IBAction func dictionaries(_ sender: AnyObject) {
        showWindow(storyBoardName: "Dicts", windowControllerName: "DictsWindowController", modal: false)
    }
    
    @IBAction func readNumber(_ sender: AnyObject) {
        showWindow(storyBoardName: "Misc", windowControllerName: "ReadNumberWindowController", modal: false)
    }
    
    func searchWord(word: String) {
        guard let w = NSApplication.shared.windows.first(where: { $0.windowController?.className.contains( "WordsSearchWindowController") ?? false }) else {return}
        let v = w.contentViewController as! WordsSearchViewController
        v.addNewWord(word: word)
    }
}
