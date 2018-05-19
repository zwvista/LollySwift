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

    fileprivate let _theSettingsViewModel = SettingsViewModel()
    static var theSettingsViewModel: SettingsViewModel {
        return (NSApplication.shared.delegate as! AppDelegate)._theSettingsViewModel
    }
    
    let disposeBag = DisposeBag()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        _theSettingsViewModel.getData().subscribe(onNext: {
            self.wordsInUnit(self)
        }).disposed(by: disposeBag)
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed() -> Bool {
        return true
    }
    
    func showWindow(storyBoardName: String, windowControllerName: String, modal: Bool) {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: storyBoardName), bundle: nil)
        let wc = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: windowControllerName)) as! NSWindowController
        if modal {
            NSApplication.shared.runModal(for: wc.window!)
        } else {
            wc.showWindow(self)
        }
    }
    
    @IBAction func search(_ sender: AnyObject) {
        showWindow(storyBoardName: "Main", windowControllerName: "SearchWindowController", modal: false)
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
}
