//
//  WordsUnitView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/15.
//

import SwiftUI

struct WordsUnitView: View {
    @StateObject var vm = WordsUnitViewModel(settings: vmSettings, inTextbook: true, needCopy: false) {}
    @Environment(\.editMode) var editMode
    var isEditing: Bool { editMode?.wrappedValue.isEditing == true }
    @State var showDetail = false
    @State var showBatchEdit = false
    @State var showDict = false
    @State var showListMore = false
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
                        VStack {
                            Text(item.UNITSTR)
                            Text(item.PARTSTR)
                            Text("\(item.SEQNUM)")
                        }
                        .font(.caption)
                        .foregroundColor(Color.color1)
                        VStack(alignment: .leading) {
                            Text(item.WORD)
                                .font(.title)
                                .foregroundColor(Color.color2)
                            Text(item.NOTE)
                                .foregroundColor(Color.color3)
                        }
                        Spacer()
                        if !isEditing {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .onTapGesture {
                                    showDict.toggle()
                                }
                        }
                    }
                    // https://stackoverflow.com/questions/65100077/swiftui-how-can-you-use-on-tap-gesture-for-entire-item-in-a-foreach-loop
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        if isEditing {
                            showDetail.toggle()
                        } else {
                            LollySwiftUIiOSApp.speak(string: item.WORD)
                        }
                    }
                    .sheet(isPresented: $showDetail) {
                        WordsUnitDetailView(vmEdit: getVmEdit(vm: vm, item: item, phraseid: 0), showDetail: $showDetail)
                    }
                    .sheet(isPresented: $showDict) {
                        WordsDictView()
                    }
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
            .alert(Text("Word"), isPresented: $showListMore, actions: {
                Button("Retrieve All Notes") {
                    getNotes(ifEmpty: false)
                }
                Button("Retrieve Notes If Empty") {
                    getNotes(ifEmpty: true)
                }
                Button("Clear All Notes") {
                    Task {
                        await vm.clearNotes(ifEmpty: false) { _ in }
                    }
                }
                Button("Clear Notes If Empty") {
                    Task {
                        await vm.clearNotes(ifEmpty: true) { _ in }
                    }
                }
                Button("Batch Edit") {
                    showBatchEdit = true
                }
                Button("Cancel") {}
            }, message: {
                Text("More")
            })
            .sheet(isPresented: $showBatchEdit) {
                WordsUnitBatchEditView()
            }
        }
    }

    func getNotes(ifEmpty: Bool) {
        Task {
            await vm.getNotes(ifEmpty: ifEmpty, oneComplete: { _ in }, allComplete: {
            })
        }
    }

    func getVmEdit(vm: WordsUnitViewModel, item: MUnitWord, phraseid: Int) -> WordsUnitDetailViewModel {
        WordsUnitDetailViewModel(vm: vm, item: item, phraseid: phraseid) {}
    }
}

struct WordsUnitView_Previews: PreviewProvider {
    static var previews: some View {
        WordsUnitView()
    }
}
