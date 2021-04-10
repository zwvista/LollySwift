//
//  LoginViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2021/04/09.
//  Copyright © 2021 趙 偉. All rights reserved.
//

import UIKit

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
        vm.login().subscribe(onNext: {
            CommonApi.userid = $0
            if CommonApi.userid == 0 {
                let alert: UIAlertController = UIAlertController(title: "Login", message:  "Wrong Username or Password", preferredStyle:  UIAlertController.Style.alert)
                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {_ in }
                alert.addAction(defaultAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                UserDefaults.standard.set(CommonApi.userid, forKey: "userid")
                self.dismiss(animated: true, completion: self.completion)
            }
        }) ~ rx.disposeBag
    }
}
