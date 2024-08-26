//
//  ReviewOptionsView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2023/01/07.
//

import SwiftUI

struct ReviewOptionsView: View {
    @StateObject var vm: ReviewOptionsViewModel
    @Binding var showOptions: Bool
    @Binding var showOptionsDone: Bool
    var body: some View {
        NavigationView {
            Form {
                HStack {
                    Text("Mode:")
                    Spacer()
                    Picker("", selection: $vm.optionsEdit.mode) {
                        ForEach(SettingsViewModel.reviewModes.indices, id: \.self) {
                            Text(SettingsViewModel.reviewModes[$0])
                        }
                    }
                }
                HStack {
                    Text("Order(Shuffled):")
                    Spacer()
                    Toggle("", isOn: $vm.optionsEdit.shuffled)
                }
                HStack {
                    Text("Speak(Enabled):")
                    Spacer()
                    Toggle("", isOn: $vm.optionsEdit.speakingEnabled)
                }
                HStack {
                    Text("On Repeat:")
                    Spacer()
                    Toggle("", isOn: $vm.optionsEdit.onRepeat)
                }
                HStack {
                    Text("Forward:")
                    Spacer()
                    Toggle("", isOn: $vm.optionsEdit.moveForward)
                }
                // https://stackoverflow.com/questions/58733003/how-to-create-textfield-that-only-accepts-numbers
                HStack {
                    Text("Interval:")
                    Spacer()
                    TextField("Interval", text: Binding(
                        get: { String(vm.optionsEdit.interval) },
                        set: { vm.optionsEdit.interval = Int($0) ?? 0 }
                    ))
                }
                HStack {
                    Text("Group:")
                    Spacer()
                    TextField("Group", text: Binding(
                        get: { String(vm.optionsEdit.groupSelected) },
                        set: { vm.optionsEdit.groupSelected = Int($0) ?? 0 }
                    ))
                }
                HStack {
                    Text("Groups:")
                    Spacer()
                    TextField("Groups", text: Binding(
                        get: { String(vm.optionsEdit.groupCount) },
                        set: { vm.optionsEdit.groupCount = Int($0) ?? 0 }
                    ))
                }
                HStack {
                    Text("Review:")
                    Spacer()
                    TextField("Review", text: Binding(
                        get: { String(vm.optionsEdit.reviewCount) },
                        set: { vm.optionsEdit.reviewCount = Int($0) ?? 0 }
                    ))
                }
            }
            .navigationBarItems(leading: Button("Cancel", role: .cancel) {
                showOptions.toggle()
            }, trailing: Button("Done") {
                vm.onOK()
                showOptions.toggle()
                showOptionsDone.toggle()
            })
        }
    }
}

struct ReviewOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewOptionsView(vm: ReviewOptionsViewModel(options: MReviewOptions()), showOptions: .constant(true), showOptionsDone: .constant(false))
    }
}
