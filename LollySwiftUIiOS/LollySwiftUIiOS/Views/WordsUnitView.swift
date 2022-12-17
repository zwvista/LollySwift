//
//  WordsUnitView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/15.
//

import SwiftUI

struct WordsUnitView: View {
    @StateObject var vm = WordsUnitViewModel(settings: vmSettings, inTextbook: true, needCopy: false) {
    }
    var body: some View {
        VStack {
            List(vm.arrWords, id: \.ID) { row in
                HStack {
                    VStack {
                        Text(row.UNITSTR)
                            .font(.caption)
                            .foregroundColor(Color("Color1"))
                        Text(row.PARTSTR)
                            .font(.caption)
                            .foregroundColor(Color("Color1"))
                        Text(row.SEQNUM.description)
                            .font(.caption)
                            .foregroundColor(Color("Color1"))
                    }
                    VStack(alignment: .leading) {
                        Text(row.WORD)
                            .font(.title)
                            .foregroundColor(Color("Color2"))
                        Text(row.NOTE)
                            .foregroundColor(Color("Color3"))
                    }
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
