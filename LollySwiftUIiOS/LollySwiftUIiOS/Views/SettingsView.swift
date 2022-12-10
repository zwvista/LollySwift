//
//  SettingsView.swift
//  LollySwiftUIiOS
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
                    ForEach(0..<vm.arrLanguages.count, id: \.self) {
                        Text(vm.arrLanguages[$0].LANGNAME)
                    }
                }
                .onChange(of: vm.selectedLangIndex) {
                    print("selectedLangIndex=\($0)")
                    Task {
                        await vm.updateLang()
                    }
                }
            }
            Section(header: Text("Voice:")) {
                Picker("", selection: $vm.selectediOSVoiceIndex) {
                    ForEach(0..<vm.arriOSVoices.count, id: \.self) {
                        Text(vm.arriOSVoices[$0].VOICENAME)
                    }
                }
                .onChange(of: vm.selectediOSVoiceIndex) {
                    print("selectediOSVoiceIndex=\($0)")
                    Task {
                        await vm.updateiOSVoice()
                    }
                }
            }
            Section(header: Text("Dictionary(Reference):")) {
                Picker("", selection: $vm.selectedDictReferenceIndex) {
                    ForEach(0..<vm.arrDictsReference.count, id: \.self) {
                        Text(vm.arrDictsReference[$0].DICTNAME)
                    }
                }
                .onChange(of: vm.selectedDictReferenceIndex) {
                    print("selectedDictReferenceIndex=\($0)")
                    Task {
                        await vm.updateDictReference()
                    }
                }
            }
            Section(header: Text("Dictionary(Note):")) {
                Picker("", selection: $vm.selectedDictNoteIndex) {
                    ForEach(0..<vm.arrDictsNote.count, id: \.self) {
                        Text(vm.arrDictsNote[$0].DICTNAME)
                    }
                }
                .onChange(of: vm.selectedDictNoteIndex) {
                    print("selectedDictNoteIndex=\($0)")
                    Task {
                        await vm.updateDictNote()
                    }
                }
            }
            Section(header: Text("Dictionary(Translation):")) {
                Picker("", selection: $vm.selectedDictTranslationIndex) {
                    ForEach(0..<vm.arrDictsTranslation.count, id: \.self) {
                        Text(vm.arrDictsTranslation[$0].DICTNAME)
                    }
                }
                .onChange(of: vm.selectedDictTranslationIndex) {
                    print("selectedDictTranslationIndex=\($0)")
                    Task {
                        await vm.updateDictTranslation()
                    }
                }
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
