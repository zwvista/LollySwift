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
    @Environment(\.editMode) var editMode
    var isEditing: Bool { editMode?.wrappedValue.isEditing == true }
    @State var showDetailEdit = false
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
                        if isEditing {
                            showDetailEdit = true
                        } else {
                            AppDelegate.speak(string: item.PHRASE)
                        }
                    }
                    .sheet(isPresented: $showDetailEdit) {
                        PhrasesTextbookDetailView(vmEdit: PhrasesUnitDetailViewModel(vm: vm, item: item, wordid: 0, complete: {}), showDetail: $showDetailEdit)
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
                .onDelete { IndexSet in

                }
            }
        }
    }
}
