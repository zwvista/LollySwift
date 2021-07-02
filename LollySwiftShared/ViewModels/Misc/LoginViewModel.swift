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

class LoginViewModel: NSObject, ObservableObject {

#if SWIFTUI
    @Published var username = ""
    @Published var password = ""
#else
    let username = BehaviorRelay(value: "")
    let password = BehaviorRelay(value: "")
#endif

    func login(username: String, password: String) -> Observable<String> {
        MUser.getData(username: username, password: password)
            .map {
                $0.isEmpty ? "" : $0[0].USERID
            }
    }
}
