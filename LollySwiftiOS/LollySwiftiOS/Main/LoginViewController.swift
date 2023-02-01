//
//  LoginViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2021/04/09.
//  Copyright © 2021 趙 偉. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa

class LoginViewController: UIViewController {

    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!

    let vm = LoginViewModel()
    var completion: (() -> Void)?
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
                    dismiss(animated: true, completion: completion)
                } else {
                    let alert = UIAlertController(title: "Login", message:  "Wrong username or password!", preferredStyle:  UIAlertController.Style.alert)
                    let defaultAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {_ in }
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true)
                }
            }
        } ~ subscriptions
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
