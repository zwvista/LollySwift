//
//  ReadNumberViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/10/12.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa

class ReadNumberViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var tfNumber: NSTextField!
    @IBOutlet weak var tfText: NSTextField!
    
    @objc dynamic var vm: ReadNumberViewModel!
    private var _observers = [NSKeyValueObservation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        vm = ReadNumberViewModel()
        _observers.append(observe(\.vm.text, options: .new){_,change in
            self.tfText.stringValue = change.newValue!
        })
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        _observers.removeAll()
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        let textfield = obj.object as! NSControl
        let code = (obj.userInfo!["NSTextMovement"] as! NSNumber).intValue
        guard code == NSReturnTextMovement else {return}
        guard textfield === tfNumber else {return}
        guard let _ = Int(tfNumber.stringValue) else {return}
        vm.read()
    }
        
    deinit {
        print("DEBUG: \(self.className) deinit")
    }

}

class ReadNumberWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
        
    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
