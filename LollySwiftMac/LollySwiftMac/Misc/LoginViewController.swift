//
//  LoginViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2021/04/10.
//  Copyright © 2021 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import RxBinding

class LoginViewController: NSViewController {

    let vm = LoginViewModel()

    @IBOutlet weak var tfUsername: NSTextField!
    @IBOutlet weak var tfPassword: NSSecureTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        _ = vm.username <~> tfUsername.rx.text.orEmpty
        _ = vm.password <~> tfPassword.rx.text.orEmpty
    }

    @IBAction func login(_ sender: Any) {
        vm.login(username: vm.username.value, password: vm.password.value).subscribe(onSuccess: {
            globalUser.userid = $0
            if globalUser.userid.isEmpty {
                let alert = NSAlert()
                alert.alertStyle = .critical
                alert.messageText = "Login"
                alert.informativeText = "Wrong Username or Password!"
                alert.addButton(withTitle: "OK")
                alert.runModal()
            } else {
                UserDefaults.standard.set(globalUser.userid, forKey: "userid")
                NSApplication.shared.stopModal(withCode: .OK)
                self.view.window?.close()
            }
        }) ~ rx.disposeBag
    }

    @IBAction func exit(_ sender: Any) {
        NSApplication.shared.stopModal(withCode: .cancel)
        self.view.window?.close()
    }
}
