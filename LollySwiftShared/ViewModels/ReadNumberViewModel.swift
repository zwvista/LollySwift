//
//  ReadNumberViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/10/12.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation

class ReadNumber {
    class func readInJapanese(num: Int) -> String {
        let numbers1 = ["ゼロ", "いち", "に", "さん", "よん", "ご", "ろく", "なな", "はち", "きゅう", "じゅう", "まん", "おく", "ちょう"]
        let numbers3 = ["ひゃく", "にひゃく", "さんびゃく", "よんひゃく", "ごひゃく", "ろっぴゃく", "ななひゃく", "はっぴゃく", "きゅうひゃく"]
        let numbers4 = ["せん", "にせん", "さんぜん", "よんせん", "ごせん", "ろっせん", "ななせん", "はっせん", "きゅうせん"]
        let num = num % 1_0000_0000
        func f(n: Int, unit: String) -> String {
            let (n4, n3, n2, n1) = (n / 1000, n % 1000 / 100, n % 100 / 10, n % 10)
            var s = n4 == 0 ? "" : numbers4[n4]
            s += n3 == 0 ? "" : numbers3[n3]
            s += n2 == 0 ? "" : n2 == 1 ? numbers1[10] : numbers1[n2] + numbers1[10]
            s += n1 == 0 ? "" : numbers1[n1]
            return s + unit
        }
        if num == 0 {
            return numbers1[0]
        } else {
            let n5 = num / 10000
            let s1 = n5 == 0 ? "" : f(n: n5, unit: numbers1[11])
            let n1 = num % 10000
            let s2 = n1 == 0 ? "" : f(n: n1, unit: "")
            return s1.isEmpty || s2.isEmpty ? s1 + s2 : s1 + " " + s2
        }
    }
    class func readInNativeKorean(num: Int) -> String {
        let numbers1 = ["", "하나", "둘", "셋", "넷", "다섯", "여섯", "일곱", "여덟", "아홉"]
        let numbers2 = ["", "열", "스물", "서른", "마흔", "쉰", "예순", "일흔", "여든", "아흔"]
        let num = num % 100
        let (n2, n1) = (num / 10, num % 10)
        let s1 = numbers2[n2]
        let s2 = numbers1[n1]
        return s1.isEmpty || s2.isEmpty ? s1 + s2 : s1 + " " + s2
    }
    class func readInSinoKorean(num: Int) -> String {
        let numbers = ["영", "일", "이", "삼", "사", "오", "육", "칠", "팔", "구", "십", "백", "천", "만", "억", "조"]
        let num = num % 1_0000_0000
        func g(n: Int, unit: Int) -> String {
            return n == 0 ? "" : n == 1 ? numbers[unit] : numbers[n] + numbers[unit]
        }
        func f(n: Int, unit: String) -> String {
            let (n4, n3, n2, n1) = (n / 1000, n % 1000 / 100, n % 100 / 10, n % 10)
            var s = g(n: n4, unit: 12)
            s += g(n: n3, unit: 11)
            s += g(n: n2, unit: 10)
            s += n1 == 0 ? "" : numbers[n1]
            return s + unit
        }
        if num == 0 {
            return numbers[0]
        } else {
            let n5 = num / 10000
            let s1 = n5 == 0 ? "" : n5 == 1 ? numbers[13] : f(n: n5, unit: numbers[13])
            let n1 = num % 10000
            let s2 = n1 == 0 ? "" : f(n: n1, unit: "")
            return s1.isEmpty || s2.isEmpty ? s1 + s2 : s1 + " " + s2
        }
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
