//
//  PhrasesUnitView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/15.
//

import SwiftUI

struct PhrasesUnitView: View {
    @StateObject var vm = PhrasesUnitViewModel(settings: vmSettings, inTextbook: true, needCopy: false) {
    }
    var body: some View {
        VStack {
            List(vm.arrPhrases, id: \.ID) { row in
                Text(row.PHRASE)
            }
        }
    }
}

struct PhrasesUnitView_Previews: PreviewProvider {
    static var previews: some View {
        WordsUnitView()
    }
}
