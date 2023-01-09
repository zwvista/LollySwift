//
//  WordsReviewView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/30.
//

import SwiftUI

struct WordsReviewView: View {
    @StateObject var vm = WordsReviewViewModel(settings: vmSettings, needCopy: false) {}
    @State var showOptons = true
    var body: some View {
        VStack {
            HStack {
                Text(vm.indexString)
                    .isHidden(vm.indexHidden)
                Spacer()
                Text(vm.accuracyString)
                    .isHidden(vm.accuracyHidden)
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
            Text(vm.wordTargetString)
                .isHidden(vm.wordTargetHidden)
            Text(vm.noteTargetString)
                .isHidden(vm.noteTargetHidden)
            Text(vm.translationString)
            TextField("", text: $vm.wordInputString)
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showOptons) {
            ReviewOptionsView(vm: ReviewOptionsViewModel(options: vm.options), showOptions: $showOptons)
        }
    }
}

struct WordsReviewView_Previews: PreviewProvider {
    static var previews: some View {
        WordsReviewView()
    }
}