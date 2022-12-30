//
//  PhrasesUnitView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/15.
//

import SwiftUI

struct PhrasesUnitView: View {
    @StateObject var vm = PhrasesUnitViewModel(settings: vmSettings, inTextbook: true, needCopy: false) {}
    @Environment(\.editMode) var editMode
    var isEditing: Bool { editMode?.wrappedValue.isEditing == true }
    @State var showDetailEdit = false
    @State var showDetailAdd = false
    @State var showBatchEdit = false
    @State var showItemMore = false
    @State var showListMore = false
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
                        PhrasesUnitDetailView(vmEdit: PhrasesUnitDetailViewModel(vm: vm, item: item, wordid: 0, complete: {}), showDetail: $showDetailEdit)
                    }
                    .swipeActions(allowsFullSwipe: false) {
                        Button("More") {
                            showItemMore.toggle()
                        }
                        Button("Delete") {
                            
                        }
                        .tint(Color.red)
                    }
                    .alert(Text("Word"), isPresented: $showItemMore, actions: {
                        Button("Delete") {
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
                        Button("Cancel") {}
                    }, message: {
                        Text(item.PHRASE)
                    })
                }
                .onDelete { IndexSet in

                }
            }
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
                    showBatchEdit = true
                }
                Button("Cancel") {}
            }, message: {
                Text("More")
            })
            .sheet(isPresented: $showDetailAdd) {
                PhrasesUnitDetailView(vmEdit: PhrasesUnitDetailViewModel(vm: vm, item: vm.newUnitPhrase(), wordid: 0, complete: {}), showDetail: $showDetailAdd)
            }
            .sheet(isPresented: $showBatchEdit) {
                PhrasesUnitBatchEditView()
            }
        }
    }
}
