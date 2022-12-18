//
//  WordsUnitView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/15.
//

import SwiftUI

struct WordsUnitView: View {
    @StateObject var vm = WordsUnitViewModel(settings: vmSettings, inTextbook: true, needCopy: false) {}
    var body: some View {
        VStack {
            List {
                ForEach(vm.arrWords, id: \.ID) { row in
                    HStack {
                        VStack {
                            Text(row.UNITSTR)
                            Text(row.PARTSTR)
                            Text("\(row.SEQNUM)")
                        }
                        .font(.caption)
                        .foregroundColor(Color.color1)
                        VStack(alignment: .leading) {
                            Text(row.WORD)
                                .font(.title)
                                .foregroundColor(Color.color2)
                            Text(row.NOTE)
                                .foregroundColor(Color.color3)
                        }
                    }
                }.onDelete { IndexSet in
                    
                }
            }.toolbar {
                EditButton()
            }
        }
    }
}

struct WordsUnitView_Previews: PreviewProvider {
    static var previews: some View {
        WordsUnitView()
    }
}