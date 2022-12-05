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
    @IBOutlet weak var btnLogin: NSButton!
    @IBOutlet weak var btnExit: NSButton!

    let vm = LoginViewModel()
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        vm.$username <~> tfUsername.textProperty ~ subscriptions
        vm.$password <~> tfPassword.textProperty ~ subscriptions

        btnLogin.tapPublisher.sink { [unowned self] in
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
        } ~ subscriptions

        btnExit.tapPublisher.sink { [unowned self] in
            NSApplication.shared.stopModal(withCode: .cancel)
            self.view.window?.close()
        } ~ subscriptions
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
