//
//  LoginViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2021/04/09.
//  Copyright © 2021 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class LoginViewModel: NSObject {
    let username = BehaviorRelay(value: "")
    let password = BehaviorRelay(value: "")
    
    func login() -> Observable<String> {
        MUser.getData(username: username.value, password: password.value)
            .map {
                $0.isEmpty ? "" : $0[0].USERID
            }
    }
}
