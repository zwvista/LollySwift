//
//  LoginView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2021/06/27.
//

import SwiftUI

struct LoginView: View {
    @StateObject var vm = LoginViewModel()
    @State var showingAlert = false
    var body: some View {
        VStack {
            Text("Lolly")
                .font(.largeTitle)
            Form {
                Section {
                    TextField("USERNAME", text: $vm.username)
                    SecureField("PASSWORD", text: $vm.password)
                    Button(action: {
                        Task {
                            globalUser.userid = await vm.login(username: vm.username, password: vm.password)
                            if globalUser.isLoggedIn {
                                globalUser.save()
                            } else {
                                showingAlert = true
                            }
                        }
                    }) {
                        Text("Login")
                    }
                    .frame(maxWidth: .infinity)
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
