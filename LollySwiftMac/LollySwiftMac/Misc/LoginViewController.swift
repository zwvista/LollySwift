//
//  LoginViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2021/04/10.
//  Copyright © 2021 趙偉. All rights reserved.
//

import UIKit
import RxSwift

class LoginViewController: UIViewController {

    let vm = LoginViewModel()

    @IBOutlet weak var tfUsername: NSTextField!
    @IBOutlet weak var tfPassword: NSSecureTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        _ = vm.username <~> tfUsername.rx.textInput
        _ = vm.password <~> tfPassword.rx.textInput
    }

}
