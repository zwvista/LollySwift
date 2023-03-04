//
//  LoginViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2021/04/09.
//  Copyright © 2021 趙 偉. All rights reserved.
//

import UIKit
import RxBinding

class LoginViewController: UIViewController {

    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var tfPassword: UITextField!

    let vm = LoginViewModel()
    var completion: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        _ = vm.username <~> tfUsername.rx.textInput
        _ = vm.password <~> tfPassword.rx.textInput
    }

    @IBAction func login(_ sender: Any) {
        vm.login(username: vm.username.value, password: vm.password.value).subscribe { [unowned self] in
            globalUser.userid = $0
            if globalUser.isLoggedIn {
                globalUser.save()
                dismiss(animated: true, completion: completion)
            } else {
                let alert = UIAlertController(title: "Login", message:  "Wrong username or password!", preferredStyle:  UIAlertController.Style.alert)
                let defaultAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {_ in }
                alert.addAction(defaultAction)
                present(alert, animated: true)
            }
        } ~ rx.disposeBag
    }
}
