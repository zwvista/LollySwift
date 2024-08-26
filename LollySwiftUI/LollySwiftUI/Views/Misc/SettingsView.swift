//
//  SettingsView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2021/06/29.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var vm = vmSettings
    var body: some View {
        Form {
            Section(header: Text("Language:")) {
                Picker("", selection: $vm.selectedLangIndex) {
                    ForEach(vm.arrLanguages.indices, id: \.self) {
                        Text(vm.arrLanguages[$0].LANGNAME)
                    }
                }
            }
            Section(header: Text("Voice:")) {
                Picker("", selection: $vm.selectediOSVoiceIndex) {
                    ForEach(vm.arriOSVoices.indices, id: \.self) {
                        Text(vm.arriOSVoices[$0].VOICENAME)
                    }
                }
            }
            Section(header: Text("Dictionary(Reference):")) {
                Picker("", selection: $vm.selectedDictReferenceIndex) {
                    ForEach(vm.arrDictsReference.indices, id: \.self) {
                        Text(vm.arrDictsReference[$0].DICTNAME)
                    }
                }
            }
            Section(header: Text("Dictionary(Note):")) {
                Picker("", selection: $vm.selectedDictNoteIndex) {
                    ForEach(vm.arrDictsNote.indices, id: \.self) {
                        Text(vm.arrDictsNote[$0].DICTNAME)
                    }
                }
            }
            Section(header: Text("Dictionary(Translation):")) {
                Picker("", selection: $vm.selectedDictTranslationIndex) {
                    ForEach(vm.arrDictsTranslation.indices, id: \.self) {
                        Text(vm.arrDictsTranslation[$0].DICTNAME)
                    }
                }
            }
            Section(header: Text("Textbook:")) {
                Picker("", selection: $vm.selectedTextbookIndex) {
                    ForEach(vm.arrTextbooks.indices, id: \.self) {
                        Text(vm.arrTextbooks[$0].TEXTBOOKNAME)
                    }
                }
            }
            Section(header: Text("Units & Parts:")) {
                Picker("Unit", selection: $vm.selectedUnitFromIndex) {
                    ForEach(vm.arrUnits.indices, id: \.self) {
                        Text(vm.arrUnits[$0].label)
                    }
                }
                Picker("Part", selection: $vm.selectedPartFromIndex) {
                    ForEach(vm.arrParts.indices, id: \.self) {
                        Text(vm.arrParts[$0].label)
                    }
                }
                .disabled(!vm.partFromEnabled)
                HStack {
                    Picker("", selection: $vm.toType) {
                        ForEach(SettingsViewModel.arrToTypes.indices, id: \.self) {
                            Text(SettingsViewModel.arrToTypes[$0])
                        }
                    }
                    .labelsHidden()
                    Spacer()
                    Button("Previous") {
                        Task {
                            await vm.previousUnitPart()
                        }
                    }
                    .disabled(!vm.previousEnabled)
                    Spacer()
                    Button("Next") {
                        Task {
                            await vm.nextUnitPart()
                        }
                    }
                    .disabled(!vm.nextEnabled)
                }
                Picker("Unit", selection: $vm.selectedUnitToIndex) {
                    ForEach(vm.arrUnits.indices, id: \.self) {
                        Text(vm.arrUnits[$0].label)
                    }
                }
                .disabled(!vm.unitToEnabled)
                Picker("Part", selection: $vm.selectedPartToIndex) {
                    ForEach(vm.arrParts.indices, id: \.self) {
                        Text(vm.arrParts[$0].label)
                    }
                }
                .disabled(!vm.partToEnabled)
            }
        }.onAppear {
            Task {
                await vm.getData()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
