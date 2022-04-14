//
//  LoginView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2021/06/27.
//

import SwiftUI
import RxSwift
import RxBinding

struct LoginView: View {
    @StateObject var vm = LoginViewModel()
    @State var showingAlert = false
    let disposeBag = DisposeBag()
    var body: some View {
        VStack {
            Text("Lolly")
                .font(.largeTitle)
            Form {
                Section {
                    TextField("USERNAME", text: $vm.username)
                    SecureField("PASSWORD", text: $vm.password)
                    Button(action: {
                        vm.login(username: vm.username, password: vm.password).subscribe(onSuccess: {
                            globalUser.userid = $0
                            if globalUser.userid.isEmpty {
                                showingAlert = true
                            } else {
                                UserDefaults.standard.set(globalUser.userid, forKey: "userid")
                            }
                        }) ~ disposeBag
                    }) {
                        Text("Login")
                    }.frame(maxWidth: .infinity)
                }
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Login"), message: Text("Wrong Username or Password!"))
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
