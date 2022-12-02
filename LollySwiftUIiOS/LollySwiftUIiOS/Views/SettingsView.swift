//
//  SettingsView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2021/06/29.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var vm = vmSettings
    let disposeBag = DisposeBag()
    var body: some View {
        Form {
            Section(header: Text("Language:")) {
                Picker(selection: $vm.selectedLangIndex, label: Text( vm.selectedLang.LANGNAME.defaultIfEmpty("Language"))) {
                    ForEach(0..<vm.arrLanguages.count, id: \.self) {
                        Text(vm.arrLanguages[$0].LANGNAME)
                    }
                }.frame(maxWidth: .infinity)
                .padding()
                .pickerStyle(MenuPickerStyle())
                .onChange(of: vm.selectedLangIndex) {
                    print("selectedLangIndex=\($0)")
                    vm.updateLang().subscribe() ~ disposeBag
                }
            }
            Section(header: Text("Voice:")) {
                Picker(selection: $vm.selectediOSVoiceIndex, label: Text( vm.selectediOSVoice.VOICENAME.defaultIfEmpty("Voice"))) {
                    ForEach(0..<vm.arriOSVoices.count, id: \.self) {
                        Text(vm.arriOSVoices[$0].VOICENAME)
                    }
                }.frame(maxWidth: .infinity)
                .padding()
                .pickerStyle(MenuPickerStyle())
                .onChange(of: vm.selectediOSVoiceIndex) {
                    print("selectediOSVoiceIndex=\($0)")
                    vm.updateiOSVoice().subscribe() ~ disposeBag
                }
            }
        }.onAppear {
            vm.getData().subscribe() ~ disposeBag
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
