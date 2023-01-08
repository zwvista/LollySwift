//
//  PhrasesTextbookView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/30.
//

import SwiftUI

struct PhrasesTextbookView: View {
    @Binding var navPath: NavigationPath
    @StateObject var vm = PhrasesUnitViewModel(settings: vmSettings, inTextbook: false, needCopy: false) {}
    @State var showDetailEdit = false
    @State var showItemMore = false
    @State var showDelete = false
    @State var currentItem = MUnitPhrase()
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
                ForEach(vm.arrPhrasesFiltered, id: \.ID) { item in
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
                            currentItem = item
                            showItemMore.toggle()
                        }
                        Button("Delete", role: .destructive) {
                            currentItem = item
                            showDelete.toggle()
                        }
                    }
                }
            }
            .refreshable {
                await vm.reload()
            }
            .alert(Text("delete"), isPresented: $showDelete, actions: {
                Button("No", role: .cancel) {}
                Button("Yes", role: .destructive) {
                    
                }
            }, message: {
                Text(currentItem.PHRASE)
            })
            .alert(Text("Phrase"), isPresented: $showItemMore, actions: {
                Button("Delete", role: .destructive) {
                    showDelete.toggle()
                }
                Button("Edit") {
                    showDetailEdit.toggle()
                }
                Button("Copy Phrase") {
                    iOSApi.copyText(currentItem.PHRASE)
                }
                Button("Google Phrase") {
                    iOSApi.googleString(currentItem.PHRASE)
                }
            }, message: {
                Text(currentItem.PHRASE)
            })
            .sheet(isPresented: $showDetailEdit) {
                PhrasesTextbookDetailView(vmEdit: PhrasesUnitDetailViewModel(vm: vm, item: currentItem, wordid: 0, complete: {}), showDetail: $showDetailEdit)
            }
        }
    }
}
