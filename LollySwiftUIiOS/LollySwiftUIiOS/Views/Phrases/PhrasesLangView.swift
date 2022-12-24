//
//  PhrasesLangView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/15.
//

import SwiftUI

struct PhrasesLangView: View {
    @StateObject var vm = PhrasesLangViewModel(settings: vmSettings, needCopy: false) {}
    @Environment(\.editMode) var editMode
    @State var showDetail = false
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                SearchBar(text: $vm.textFilter, placeholder: "Filter") { _ in }
                Picker("", selection: $vm.scopeFilter) {
                    ForEach(SettingsViewModel.arrScopeWordFilters, id: \.self) { s in
                        Text(s)
                    }
                }
                .background(Color.color2)
                .tint(.white)
            }
            List {
                ForEach(vm.arrPhrases, id: \.ID) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.PHRASE)
                                .font(.title)
                                .foregroundColor(Color.color2)
                            Text(item.TRANSLATION)
                                .foregroundColor(Color.color3)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if editMode?.wrappedValue.isEditing == true {
                            showDetail = true
                        } else {
                            LollySwiftUIiOSApp.speak(string: item.PHRASE)
                        }
                    }
                    .sheet(isPresented: $showDetail) {
                        PhrasesLangDetailView()
                    }
                }
            }
        }
    }
}

struct PhrasesLangView_Previews: PreviewProvider {
    static var previews: some View {
        PhrasesLangView()
    }
}
