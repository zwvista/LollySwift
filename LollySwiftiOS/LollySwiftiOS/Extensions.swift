//
//  Extensions.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2018/03/27.
//  Copyright © 2018年 趙 偉. All rights reserved.
//

import Foundation

extension UIViewController {
    func yesNoAction(title: String?, message: String?, yesHandler: @escaping (UIAlertAction) -> (), noHandler: @escaping (UIAlertAction) -> ()) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: noHandler)
        alertController.addAction(noAction)
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: yesHandler)
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
