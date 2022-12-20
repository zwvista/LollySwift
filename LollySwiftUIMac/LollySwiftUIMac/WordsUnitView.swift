//
//  WordsUnitView.swift
//  LollySwiftUIMac
//
//  Created by 趙偉 on 2020/12/04.
//

import SwiftUI

struct WordsUnitView: View {
    var vm: WordsUnitViewModel!
    var arrWords: [MUnitWord] { vm.arrWordsFiltered ?? vm.arrWords }

    init() {
        vm = WordsUnitViewModel(settings: LollySwiftUIMacApp.theSettingsViewModel, inTextbook: true, needCopy: true) {

        }
    }
    var body: some View {
        VStack {
            HStack {
                Text("Hello, world!")
                    .padding()
            }
            HSplitView {
                List(arrWords, id: \.ID) {_ in

                }
            }
        }
    }
}

struct WordsUnitView_Previews: PreviewProvider {
    static var previews: some View {
        WordsUnitView()
    }
}
