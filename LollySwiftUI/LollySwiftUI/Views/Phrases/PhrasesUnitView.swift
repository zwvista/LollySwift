//
//  PhrasesUnitView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2022/12/15.
//

import SwiftUI

struct PhrasesUnitView: View {
    @Binding var navPath: NavigationPath
    @StateObject var vm = PhrasesUnitViewModel(settings: vmSettings, inTextbook: true) {}
    @Environment(\.editMode) var editMode
    var isEditing: Bool { editMode?.wrappedValue.isEditing == true }
    @State var showDetailEdit = false
    @State var showDetailAdd = false
    @State var showBatchEdit = false
    @State var showItemMore = false
    @State var showListMore = false
    @State var showDelete = false
    @State var selectedItem = MUnitPhrase()
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
                        if isEditing {
                            selectedItem = item
                            showDetailEdit.toggle()
                        } else {
                            AppDelegate.speak(string: item.PHRASE)
                        }
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
                .onDelete { IndexSet in

                }
                .onMove { source, destination in
                    
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
            .toolbar {
                ToolbarItemGroup {
                    EditButton()
                    Button("More") {
                        showListMore.toggle()
                    }
                }
            }
            .alert(Text("Phrases"), isPresented: $showListMore, actions: {
                Button("Add") {
                    showDetailAdd.toggle()
                }
                Button("Batch Edit") {
                    showBatchEdit.toggle()
                }
                Button("Cancel", role: .cancel) {}
            }, message: {
                Text("More")
            })
            .sheet(isPresented: $showDetailEdit) {
                PhrasesUnitDetailView(vmEdit: PhrasesUnitDetailViewModel(vm: vm, item: selectedItem, wordid: 0), showDetail: $showDetailEdit)
            }
            .sheet(isPresented: $showDetailAdd) {
                PhrasesUnitDetailView(vmEdit: PhrasesUnitDetailViewModel(vm: vm, item: vm.newUnitPhrase(), wordid: 0), showDetail: $showDetailAdd)
            }
            .sheet(isPresented: $showBatchEdit) {
                PhrasesUnitBatchEditView()
            }
        }
    }
}
