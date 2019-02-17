//
//  ViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import WebKit
import RxSwift

class PhrasesBaseViewController: NSViewController, LollyProtocol, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {
    
    @IBOutlet weak var tableView: NSTableView!

    let disposeBag = DisposeBag()
    var selectedPhrase = ""
    let synth = NSSpeechSynthesizer()
    var speakOrNot = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        selectedPhraseChanged()
        if speakOrNot {
            speak(self)
        }
    }
    
    func selectedPhraseChanged() {
    }
    
    @IBAction func copyPhrase(_ sender: Any) {
        MacApi.copyText(selectedPhrase)
    }
    
    @IBAction func googlePhrase(_ sender: Any) {
        MacApi.googleString(selectedPhrase)
    }

    @IBAction func speak(_ sender: Any) {
        synth.startSpeaking(selectedPhrase)
    }
    
    @IBAction func speakOrNotChanged(_ sender: Any) {
        speakOrNot = (sender as! NSSegmentedControl).selectedSegment == 1
    }

    func settingsChanged() {
        synth.setVoice(NSSpeechSynthesizer.VoiceName(rawValue: vmSettings.selectedLang.safeVoice))
    }
}

class PhrasesWindowController: NSWindowController, NSTextFieldDelegate {
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
}

