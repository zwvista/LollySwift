//
//  ReadNumberViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/10/12.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation

class ReadNumber {
    class func readInSinoKorean(num: Int) -> String {
        let numbers = ["영", "일", "이", "삼", "사", "오", "육", "칠", "팔", "구", "십", "백", "천", "만", "억", "조"]
        let num = num % 10000
        func f(_ n: Int) -> String {
            let (n1000, n100, n10, n1) = (num / 1000, num % 1000 / 100, num % 100 / 10, num % 10)
            func g(n2: Int, nunit: Int) -> String {
                return n2 == 0 ? "" : n2 == 1 ? numbers[nunit] : numbers[n2] + numbers[nunit]
            }
            var s = g(n2: n1000, nunit: 12)
            s += g(n2: n100, nunit: 11)
            s += g(n2: n10, nunit: 10)
            s += n1 == 0 ? "" : numbers[n1]
            return s
        }
        return num == 0 ? numbers[0] : f(num)
    }
    class func readInNativeKorean(num: Int) -> String {
        let numbers1 = ["", "하나", "둘", "셋", "넷", "다섯", "여섯", "일곱", "여덟", "아홉"]
        let numbers10 = ["", "열", "스물", "스물", "마흔", "쉰", "예순", "일흔", "여든", "아흔"]
        let num = num % 100
        let (n10, n1) = (num / 10, num % 10)
        if num == 0 { return "" }
        var s = numbers10[n10]
        if !s.isEmpty && n1 != 0 { s += " " }
        s += numbers1[n1]
        return s
    }
}

class ReadNumberViewModel : NSObject {
    @objc dynamic var num = 0
    @objc dynamic var text = ""
    
    func read() {
        text = ReadNumber.readInSinoKorean(num: num)
        //text = ReadNumber.readInNativeKorean(num: num)
    }
}
