//
//  PatternsView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/15.
//

import SwiftUI

struct PatternsView: View {
    @StateObject var vm = PatternsViewModel(settings: vmSettings, needCopy: false) {}
    var body: some View {
        VStack {
            List {
                ForEach(vm.arrPatterns, id: \.ID) { row in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(row.PATTERN)
                                .font(.title)
                                .foregroundColor(Color.color2)
                            Text(row.TAGS)
                                .foregroundColor(Color.color3)
                        }
                    }
                }
            }
        }
    }
}

struct PatternsView_Previews: PreviewProvider {
    static var previews: some View {
        PatternsView()
    }
}
