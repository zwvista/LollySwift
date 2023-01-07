//
//  PhrasesLangView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/15.
//

import SwiftUI

struct PhrasesLangView: View {
    @Binding var navPath: NavigationPath
    @StateObject var vm = PhrasesLangViewModel(settings: vmSettings, needCopy: false) {}
    @State var showDetailEdit = false
    @State var showDetailAdd = false
    @State var showItemMore = false
    @State var showDelete = false
    @State var currentItem = MLangPhrase()
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                SearchBar(text: $vm.textFilter, placeholder: "Filter") { _ in }
                Picker("", selection: $vm.scopeFilter) {
                    ForEach(SettingsViewModel.arrScopePhraseFilters, id: \.self) { s in
                        Text(s)
                    }
                }
                .background(Color.color2)
                .tint(.white)
            }
            List {
                ForEach(vm.arrPhrasesFiltered, id: \.ID) { item in
                    HStack {
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
            .toolbar {
                ToolbarItemGroup {
                    Button("Add") {
                        showDetailAdd.toggle()
                    }
                }
            }
            .sheet(isPresented: $showDetailEdit) {
                PhrasesLangDetailView(vmEdit: PhrasesLangDetailViewModel(vm: vm, item: currentItem, complete: {}), showDetail: $showDetailEdit)
            }
            .sheet(isPresented: $showDetailAdd) {
                PhrasesLangDetailView(vmEdit: PhrasesLangDetailViewModel(vm: vm, item: vm.newLangPhrase(), complete: {}), showDetail: $showDetailAdd)
            }
        }
    }
}
