//
//  WordsReviewViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/04/15.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import NSObject_Rx

class WordsReviewViewController: NSViewController, LollyProtocol {
    @objc dynamic var vm: WordsReviewViewModel!
    var vmSettings: SettingsViewModel { vm.vmSettings }

    @IBOutlet weak var tfIndex: NSTextField!
    @IBOutlet weak var tfCorrect: NSTextField!
    @IBOutlet weak var tfIncorrect: NSTextField!
    @IBOutlet weak var tfAccuracy: NSTextField!
    @IBOutlet weak var tfWordTarget: NSTextField!
    @IBOutlet weak var tfNoteTarget: NSTextField!
    @IBOutlet weak var tfTranslation: NSTextField!
    @IBOutlet weak var tfWordInput: NSTextField!
    @IBOutlet weak var btnCheck: NSButton!
    
    let synth = NSSpeechSynthesizer()

    func settingsChanged() {
        vm = WordsReviewViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) {
            self.tfWordInput.becomeFirstResponder()
            if self.vm.hasNext {
                if self.vm.isSpeaking {
                    self.synth.startSpeaking(self.vm.currentWord)
                }
            }
        }
        synth.setVoice(NSSpeechSynthesizer.VoiceName(rawValue: vmSettings.macVoiceName))
        newTest(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Hold a reference to the window controller in order to prevent it from being released
    // Without it, we would not be able to access its child controls afterwards
    var wc: WordsReviewWindowController!
    override func viewDidAppear() {
        super.viewDidAppear()
        wc = view.window!.windowController as? WordsReviewWindowController
        wc.scSpeak.selectedSegment = vm.isSpeaking ? 1 : 0
        settingsChanged()
    }
    override func viewWillDisappear() {
        wc = nil
        vm.subscription?.dispose()
    }
    
    @IBAction func newTest(_ sender: AnyObject) {
        let optionsVC = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "ReviewOptionsViewController") as! ReviewOptionsViewController
        optionsVC.options.copy(from: vm.options)
        optionsVC.complete = { [unowned self] in
            self.vm.options.copy(from: optionsVC.options)
            self.vm.newTest()
        }
        self.presentAsSheet(optionsVC)
    }
    
    @IBAction func wordInput(_ sender: AnyObject) {
        guard !(vm.isTestMode && vm.wordInputString.isEmpty) else {return}
        vm.check()
    }
    
    @IBAction func check(_ sender: AnyObject) {
        vm.check()
    }
    
    @IBAction func isSpeakingChanged(_ sender: AnyObject) {
        vm.isSpeaking = (sender as! NSSegmentedControl).selectedSegment == 1
        if vm.isSpeaking {
            synth.startSpeaking(vm.currentWord)
        }
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}

class WordsReviewWindowController: NSWindowController {
    
    @IBOutlet weak var scSpeak: NSSegmentedControl!

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
