//
//  GlobalUser.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2023/01/07.
//  Copyright © 2023 趙 偉. All rights reserved.
//

import Foundation

class GlobalUser {
    var userid = ""
    var username = ""

    var isLoggedIn: Bool { !userid.isEmpty }
    func load() {
        userid = UserDefaults.standard.string(forKey: "userid") ?? ""
    }
    func save() {
        UserDefaults.standard.set(userid, forKey: "userid")
    }
    func remove() {
        UserDefaults.standard.removeObject(forKey: "userid")
        userid = ""
    }
}
let globalUser = GlobalUser()
