//
//  WordsLangView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/15.
//

import SwiftUI

struct WordsLangView: View {
    @StateObject var vm = WordsLangViewModel(settings: vmSettings, needCopy: false) {}
    var body: some View {
        VStack {
            List {
                ForEach(vm.arrWords, id: \.ID) { row in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(row.WORD)
                                .font(.title)
                                .foregroundColor(Color.color2)
                            Text(row.NOTE)
                                .foregroundColor(Color.color3)
                        }
                    }
                }
            }
        }
    }
}

struct WordsLangView_Previews: PreviewProvider {
    static var previews: some View {
        WordsLangView()
    }
}
