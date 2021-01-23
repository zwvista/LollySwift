//
//  ContentView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2020/11/30.
//

import SwiftUI

struct ContentView: View {
    @State var isOpenSideMenu: Bool = false
    @State var bindText = textWordsUnit
    var body: some View {
        ZStack{
            NavigationView {
                SearchView()
                    .navigationBarItems(leading: (
                        Button(action: {
                            self.isOpenSideMenu.toggle()
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .imageScale(.large)
                    }))
            }

            SideMenuView(isOpen: $isOpenSideMenu, bindText: $bindText)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
