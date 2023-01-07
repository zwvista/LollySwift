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
            
        }
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
