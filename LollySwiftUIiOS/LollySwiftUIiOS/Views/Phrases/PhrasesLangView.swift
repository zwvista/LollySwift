//
//  PhrasesLangView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/15.
//

import SwiftUI

struct PhrasesLangView: View {
    @StateObject var vm = PhrasesLangViewModel(settings: vmSettings, needCopy: false) {}
    var body: some View {
        VStack {
            List {
                ForEach(vm.arrPhrases, id: \.ID) { row in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(row.PHRASE)
                                .font(.title)
                                .foregroundColor(Color.color2)
                            Text(row.TRANSLATION)
                                .foregroundColor(Color.color3)
                        }
                    }
                }
            }
        }
    }
}

struct PhrasesLangView_Previews: PreviewProvider {
    static var previews: some View {
        PhrasesLangView()
    }
}
