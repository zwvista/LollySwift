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
    var body: some View {
        VStack {
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
                    .sheet(isPresented: $showDetailEdit) {
                        PhrasesLangDetailView(vmEdit: PhrasesLangDetailViewModel(vm: vm, item: item, complete: {}), showDetail: $showDetailEdit)
                    }
                    .swipeActions(allowsFullSwipe: false) {
                        Button("More") {
                            showItemMore.toggle()
                        }
                        Button("Delete", role: .destructive) {
                            showDelete.toggle()
                        }
                    }
                    .alert(Text("delete"), isPresented: $showDelete, actions: {
                        Button("No", role: .cancel) {}
                        Button("Yes", role: .destructive) {
                            
                        }
                    }, message: {
                        Text(item.PHRASE)
                    })
                    .alert(Text("Phrase"), isPresented: $showItemMore, actions: {
                        Button("Delete", role: .destructive) {
                            showDelete.toggle()
                        }
                        Button("Edit") {
                            showDetailEdit.toggle()
                        }
                        Button("Copy Phrase") {
                            iOSApi.copyText(item.PHRASE)
                        }
                        Button("Google Phrase") {
                            iOSApi.googleString(item.PHRASE)
                        }
                    }, message: {
                        Text(item.PHRASE)
                    })
                }
            }
            .toolbar {
                ToolbarItemGroup {
                    Button("Add") {
                        showDetailAdd.toggle()
                    }
                }
            }
            .sheet(isPresented: $showDetailAdd) {
                PhrasesLangDetailView(vmEdit: PhrasesLangDetailViewModel(vm: vm, item: vm.newLangPhrase(), complete: {}), showDetail: $showDetailAdd)
            }
        }
    }
}
