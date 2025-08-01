//
//  PhrasesTextbookView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2022/12/30.
//

import SwiftUI

struct PhrasesTextbookView: View {
    @Binding var navPath: NavigationPath
    @StateObject var vm = PhrasesUnitViewModel(inTextbook: false)
    @State var showDetailEdit = false
    @State var showItemMore = false
    @State var showDelete = false
    @State var selectedItem = MUnitPhrase()
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $vm.textFilter, placeholder: "Filter") { _ in }
            HStack(spacing: 0) {
                Picker("", selection: $vm.stringTextbookFilter) {
                    ForEach(vmSettings.arrTextbookFilters.map(\.label), id: \.self) { s in
                        Text(s)
                    }
                }
                .modifier(PickerModifier(backgroundColor: Color.color3))
                Picker("", selection: $vm.scopeFilter) {
                    ForEach(SettingsViewModel.arrScopePhraseFilters, id: \.self) { s in
                        Text(s)
                    }
                }
                .modifier(PickerModifier(backgroundColor: Color.color2))
            }
            List {
                ForEach(vm.arrPhrases, id: \.ID) { item in
                    HStack {
                        VStack {
                            Text(item.UNITSTR)
                            Text(item.PARTSTR)
                            Text("\(item.SEQNUM)")
                        }
                        .font(.caption)
                        .foregroundColor(Color.color1)
                        VStack(alignment: .leading) {
                            Text(item.PHRASE)
                                .font(.title)
                                .foregroundColor(Color.color2)
                            Text(item.TRANSLATION)
                                .foregroundColor(Color.color3)
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        AppDelegate.speak(string: item.PHRASE)
                    }
                    .swipeActions(allowsFullSwipe: false) {
                        Button("More") {
                            selectedItem = item
                            showItemMore.toggle()
                        }
                        Button("Delete", role: .destructive) {
                            selectedItem = item
                            showDelete.toggle()
                        }
                    }
                }
            }
            .task {
                await vm.reload()
            }
            .refreshable {
                await vm.reload()
            }
            .alert(Text("delete"), isPresented: $showDelete, actions: {
                Button("No", role: .cancel) {}
                Button("Yes", role: .destructive) {
                    
                }
            }, message: {
                Text(selectedItem.PHRASE)
            })
            .alert(Text("Phrase"), isPresented: $showItemMore, actions: {
                Button("Delete", role: .destructive) {
                    showDelete.toggle()
                }
                Button("Edit") {
                    showDetailEdit.toggle()
                }
                Button("Copy Phrase") {
                    iOSApi.copyText(selectedItem.PHRASE)
                }
                Button("Google Phrase") {
                    iOSApi.googleString(selectedItem.PHRASE)
                }
            }, message: {
                Text(selectedItem.PHRASE)
            })
            .sheet(isPresented: $showDetailEdit) {
                PhrasesTextbookDetailView(vmEdit: PhrasesUnitDetailViewModel(vm: vm, item: selectedItem, wordid: 0), showDetail: $showDetailEdit)
            }
        }
    }
}
