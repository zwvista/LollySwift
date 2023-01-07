//
//  PhrasesReviewView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/30.
//

import SwiftUI

struct PhrasesReviewView: View {
    @StateObject var vm = PhrasesReviewViewModel(settings: vmSettings, needCopy: false) {}
    @State var showOptons = true
    var body: some View {
        VStack {
            HStack {
                if !vm.indexHidden {
                    Text(vm.indexString)
                }
                Spacer()
                ZStack {
                    if !vm.correctHidden {
                        Text("Correct")
                            .foregroundColor(Color.green)
                    }
                    if !vm.incorrectHidden {
                        Text("Incorrect")
                            .foregroundColor(Color.red)
                    }
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
        }
        .padding()
        .sheet(isPresented: $showOptons) {
            ReviewOptionsView(vm: ReviewOptionsViewModel(options: vm.options), showOptions: $showOptons)
        }
    }
}

struct PhrasesReviewView_Previews: PreviewProvider {
    static var previews: some View {
        PhrasesReviewView()
    }
}
