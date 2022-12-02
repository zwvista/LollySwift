//
//  LoginViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2021/04/09.
//  Copyright © 2021 趙 偉. All rights reserved.
//

import Foundation

class LoginViewModel: NSObject, ObservableObject {

    @Published var username = ""
    @Published var password = ""

    func login(username: String, password: String) async -> String {
        let arr = await MUser.getData(username: username, password: password)
        return arr.isEmpty ? "" : arr[0].USERID
    }
}
