//
//  LoginViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2021/04/10.
//  Copyright © 2021 趙偉. All rights reserved.
//

import Cocoa
import Combine
import Then

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
                if globalUser.isLoggedIn {
                    globalUser.save()
                    NSApplication.shared.stopModal(withCode: .OK)
                    view.window?.close()
                } else {
                    let alert = NSAlert()
                    alert.alertStyle = .critical
                    alert.messageText = "Login"
                    alert.informativeText = "Wrong Username or Password!"
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
            }
        } ~ subscriptions

        btnExit.tapPublisher.sink { [unowned self] in
            NSApplication.shared.stopModal(withCode: .cancel)
            view.window?.close()
        } ~ subscriptions
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
