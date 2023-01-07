//
//  ReviewOptionsView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2023/01/07.
//

import SwiftUI

struct ReviewOptionsView: View {
    @ObservedObject var vm: ReviewOptionsViewModel
    @Binding var showOptions: Bool
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
//                HStack {
//                    Text("Interval:")
//                    Spacer()
//                    TextField("Interval", text: $vm.optionsEdit.interval)
//                }
//                HStack {
//                    Text("Group:")
//                    Spacer()
//                    TextField("Group", text: $vm.optionsEdit.groupSelected)
//                }
//                HStack {
//                    Text("Groups:")
//                    Spacer()
//                    TextField("Groups", text: $vm.optionsEdit.groupCount)
//                }
//                HStack {
//                    Text("Review:")
//                    Spacer()
//                    TextField("Review", text: $vm.optionsEdit.reviewCount)
//                }
            }
            .navigationBarItems(leading: Button("Cancel", role: .cancel) {
                showOptions.toggle()
            }, trailing: Button("Done") {
                vm.onOK()
                showOptions.toggle()
            })
        }
    }
}

struct ReviewOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewOptionsView(vm: ReviewOptionsViewModel(options: MReviewOptions()), showOptions: .constant(true))
    }
}
