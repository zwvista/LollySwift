//
//  WordsLangView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/15.
//

import SwiftUI

struct WordsLangView: View {
    @StateObject var vm = WordsLangViewModel(settings: vmSettings, needCopy: false) {}
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
                ForEach(vm.arrWordsFiltered, id: \.ID) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.WORD)
                                .font(.title)
                                .foregroundColor(Color.color2)
                            Text(item.NOTE)
                                .foregroundColor(Color.color3)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if editMode?.wrappedValue.isEditing == true {
                            showDetail = true
                        } else {
                            LollySwiftUIiOSApp.speak(string: item.WORD)
                        }
                    }
                    .sheet(isPresented: $showDetail) {
                        WordsLangDetailView()
                    }
                }
            }
        }
    }
}

struct WordsLangView_Previews: PreviewProvider {
    static var previews: some View {
        WordsLangView()
    }
}
