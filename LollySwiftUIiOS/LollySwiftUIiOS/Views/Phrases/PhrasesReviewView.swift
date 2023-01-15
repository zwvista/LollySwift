//
//  PhrasesReviewView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/30.
//

import SwiftUI

struct PhrasesReviewView: View {
    @StateObject var vm = PhrasesReviewViewModel(settings: vmSettings, needCopy: false) {}
    @State var showOptions = true
    @State var showOptionsDone = false
    var body: some View {
        let showOptionsDoneBinding = Binding(
            get: { showOptionsDone },
            set: { v in
                guard v else {return}
                Task {
                    await vm.newTest()
                }
                showOptionsDone = false
            }
        )
        VStack {
            HStack {
                Text(vm.indexString)
                    .isHidden(vm.indexHidden)
                Spacer()
                ZStack {
                    Text("Correct")
                        .isHidden(vm.correctHidden)
                        .foregroundColor(Color.green)
                    Text("Incorrect")
                        .isHidden(vm.incorrectHidden)
                        .foregroundColor(Color.red)
                }
            }
            HStack {
                Button("Speak") {
                    
                }
                Spacer()
                // https://stackoverflow.com/questions/62698587/swiftui-how-to-change-text-alignment-of-label-in-toggle
                Text("Speak")
                Toggle("", isOn: $vm.isSpeaking).labelsHidden()
                Spacer()
                Button(vm.checkNextTitle) {
                    vm.check(toNext: true)
                }
            }
            HStack {
                Text("On Repeat")
                Toggle("", isOn: $vm.onRepeat).labelsHidden()
                Spacer()
                Text("Forward")
                Toggle("", isOn: $vm.moveForward).labelsHidden()
                Spacer()
                Button(vm.checkPrevTitle) {
                    vm.check(toNext: false)
                }
            }
            Spacer()
                .frame(height: 50)
            Text(vm.phraseTargetString)
                .isHidden(vm.phraseTargetHidden)
                .font(.system(size: 50))
                .foregroundColor(Color.color2)
            Text(vm.translationString)
                .font(.system(size: 50))
                .foregroundColor(Color.color3)
            TextField("", text: $vm.phraseInputString)
            Spacer()
        }
        .padding()
        .onDisappear {
            vm.stopTimer()
        }
        .toolbar {
            Button("New Test") {
                showOptions.toggle()
            }
        }
        .sheet(isPresented: $showOptions) {
            ReviewOptionsView(vm: ReviewOptionsViewModel(options: vm.options), showOptions: $showOptions, showOptionsDone: $showOptionsDone)
        }
    }
}
