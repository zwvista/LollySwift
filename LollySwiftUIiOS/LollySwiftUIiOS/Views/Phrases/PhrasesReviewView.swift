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
                    
                }
            }
            Spacer()
            Text(vm.phraseTargetString)
                .isHidden(vm.phraseTargetHidden)
            Text(vm.translationString)
            TextField("", text: $vm.phraseInputString)
            Spacer()
        }
        .padding()
        .onAppear {
            if showOptionsDone {
                showOptionsDone.toggle()
                Task {
                    await vm.newTest()
                }
            }
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
