//
//  AppDelegate.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    static let theSettingsViewModel = SettingsViewModel()
    
    let disposeBag = DisposeBag()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        AppDelegate.theSettingsViewModel.getData().subscribe(onNext: {
            //self.search(self)
            //self.editBlog(self)
            self.wordsInUnit(self)
            //self.wordsInLanguage(self)
        }).disposed(by: disposeBag)
        // Insert code here to initialize your application

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
        return true
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
    
    @IBAction func search(_ sender: AnyObject) {
        showWindow(storyBoardName: "Words", windowControllerName: "WordsSearchWindowController", modal: false)
    }

    @IBAction func settings(_ sender: AnyObject) {
        showWindow(storyBoardName: "Main", windowControllerName: "SettingsWindowController", modal: true)
    }
    
    @IBAction func wordsInUnit(_ sender: AnyObject) {
        showWindow(storyBoardName: "Words", windowControllerName: "WordsUnitWindowController", modal: false)
    }
    
    @IBAction func phrasesInUnit(_ sender: AnyObject) {
        showWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesUnitWindowController", modal: false)
    }

    @IBAction func wordsInLanguage(_ sender: AnyObject) {
        showWindow(storyBoardName: "Words", windowControllerName: "WordsLangWindowController", modal: false)
    }
    
    @IBAction func phrasesInLanguage(_ sender: AnyObject) {
        showWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesLangWindowController", modal: false)
    }
    
    @IBAction func wordsInTextbook(_ sender: AnyObject) {
        showWindow(storyBoardName: "Words", windowControllerName: "WordsTextbookWindowController", modal: false)
    }
    
    @IBAction func phrasesInTextbook(_ sender: AnyObject) {
        showWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesTextbookWindowController", modal: false)
    }
    
    @IBAction func editBlog(_ sender: AnyObject) {
        showWindow(storyBoardName: "Main", windowControllerName: "BlogWindowController", modal: false)
    }
    
    @IBAction func wordsReview(_ sender: AnyObject) {
        showWindow(storyBoardName: "Words", windowControllerName: "WordsReviewWindowController", modal: false)
    }
    
    @IBAction func phrasesReview(_ sender: AnyObject) {
        showWindow(storyBoardName: "Phrases", windowControllerName: "PhrasesReviewWindowController", modal: false)
    }
    
    @IBAction func textbooks(_ sender: AnyObject) {
        showWindow(storyBoardName: "Tools", windowControllerName: "TextbooksWindowController", modal: false)
    }
    
    @IBAction func dictionaries(_ sender: AnyObject) {
        showWindow(storyBoardName: "Tools", windowControllerName: "DictsWindowController", modal: false)
    }
}