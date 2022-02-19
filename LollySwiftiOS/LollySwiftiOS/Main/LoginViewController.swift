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
    
    let vm = LoginViewModel()
    var completion: (() -> Void)?
    
    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _ = vm.username <~> tfUsername.rx.text.orEmpty
        _ = vm.password <~> tfPassword.rx.text.orEmpty
    }

    @IBAction func login(_ sender: Any) {
        vm.login(username: vm.username.value, password: vm.password.value).subscribe(onSuccess: {
            globalUser.userid = $0
            if globalUser.userid.isEmpty {
                let alert = UIAlertController(title: "Login", message:  "Wrong username or password!", preferredStyle:  UIAlertController.Style.alert)
                let defaultAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {_ in }
                alert.addAction(defaultAction)
                self.present(alert, animated: true)
            } else {
                UserDefaults.standard.set(globalUser.userid, forKey: "userid")
                self.dismiss(animated: true, completion: self.completion)
            }
        }) ~ rx.disposeBag
    }
}
