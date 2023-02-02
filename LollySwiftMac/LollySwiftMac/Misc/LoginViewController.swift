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

    @IBOutlet weak var tfUsername: NSTextField!
    @IBOutlet weak var tfPassword: NSSecureTextField!
    @IBOutlet weak var btnLogin: NSButton!
    @IBOutlet weak var btnExit: NSButton!

    let vm = LoginViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        _ = vm.username <~> tfUsername.rx.text.orEmpty
        _ = vm.password <~> tfPassword.rx.text.orEmpty

        btnLogin.rx.tap.flatMap { [unowned self] in
            vm.login(username: vm.username.value, password: vm.password.value)
        }.subscribe { [unowned self] userid in
            globalUser.userid = userid
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
        } ~ rx.disposeBag

        btnExit.rx.tap.subscribe { [unowned self] _ in
            NSApplication.shared.stopModal(withCode: .cancel)
            view.window?.close()
        } ~ rx.disposeBag
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
