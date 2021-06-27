//
//  LoginView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2021/06/27.
//

import SwiftUI
import RxSwift

struct LoginView: View {
    @Binding public var showLogin: Bool
    @State var vm = LoginViewModel()
    @State var showingAlert = false
    let disposeBag = DisposeBag()
    var body: some View {
        VStack {
            Text("Lolly")
                .font(.largeTitle)
            TextField("USERNAME", text: $vm.usernameUI)
            SecureField("PASSWORD", text: $vm.passwordUI)
            Button(action: {
                vm.login(username: vm.usernameUI, password: vm.passwordUI).subscribe(onNext: {
                    globalUser.userid = $0
                    if globalUser.userid.isEmpty {
                        showingAlert = true
                    } else {
                        UserDefaults.standard.set(globalUser.userid, forKey: "userid")
                        showLogin = false
                    }
                }) ~ disposeBag
            }) {
                Text("Login")
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Login"), message: Text("Wrong Username or Password!"))
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    @State static var showLogin = true
    static var previews: some View {
        LoginView(showLogin: $showLogin)
    }
}
