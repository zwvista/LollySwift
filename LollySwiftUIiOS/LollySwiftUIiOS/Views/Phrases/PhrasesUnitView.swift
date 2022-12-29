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
    @State var showDetail = false
    @State var showBatchEdit = false
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
                            showDetail = true
                        } else {
                            LollySwiftUIiOSApp.speak(string: item.PHRASE)
                        }
                    }
                    .sheet(isPresented: $showDetail) {
                        PhrasesUnitDetailView(vmEdit: getVmEdit(vm: vm, item: item, wordid: 0), showDetail: $showDetail)
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
                Button("Batch Edit") {
                    showBatchEdit = true
                }
                Button("Cancel") {}
            }, message: {
                Text("More")
            })
            .sheet(isPresented: $showBatchEdit) {
                PhrasesUnitBatchEditView()
            }
        }
    }

    func getVmEdit(vm: PhrasesUnitViewModel, item: MUnitPhrase, wordid: Int) -> PhrasesUnitDetailViewModel {
        PhrasesUnitDetailViewModel(vm: vm, item: item, wordid: wordid) {}
    }
}

struct PhrasesUnitView_Previews: PreviewProvider {
    static var previews: some View {
        WordsUnitView()
    }
}
