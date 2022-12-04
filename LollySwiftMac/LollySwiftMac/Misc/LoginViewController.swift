//
//  LoginViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2021/04/10.
//  Copyright © 2021 趙偉. All rights reserved.
//

import Cocoa
import Combine

class LoginViewController: NSViewController {

    @IBOutlet weak var tfUsername: NSTextField!
    @IBOutlet weak var tfPassword: NSSecureTextField!

    let vm = LoginViewModel()
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        vm.$username <~> tfUsername.textProperty ~ subscriptions
        vm.$password <~> tfPassword.textProperty ~ subscriptions
    }

    @IBAction func login(_ sender: Any) {
        Task {
            globalUser.userid = await vm.login(username: vm.username, password: vm.password)
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
        }
    }

    @IBAction func exit(_ sender: Any) {
        NSApplication.shared.stopModal(withCode: .cancel)
        self.view.window?.close()
    }
}
