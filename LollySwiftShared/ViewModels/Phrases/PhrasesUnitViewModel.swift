//
//  PhrasesUnitViewModel.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxBinding
import Then

class PhrasesUnitViewModel: PhrasesBaseViewModel {
    let inTextbook: Bool
    let arrPhrasesAll_ = BehaviorRelay(value: [MUnitPhrase]())
    var arrPhrasesAll: [MUnitPhrase] { get { arrPhrasesAll_.value } set { arrPhrasesAll_.accept(newValue) } }
    let arrPhrases_ = BehaviorRelay(value: [MUnitPhrase]())
    var arrPhrases: [MUnitPhrase] { get { arrPhrases_.value } set { arrPhrases_.accept(newValue) } }
    var hasFilter: Bool { !(textFilter.isEmpty && textbookFilter == 0) }

    public init(settings: SettingsViewModel, inTextbook: Bool, complete: @escaping () -> Void) {
        self.inTextbook = inTextbook
        super.init(settings: settings)

        Observable.combineLatest(arrPhrasesAll_, indexTextbookFilter_, textFilter_, scopeFilter_).subscribe { [unowned self] _ in
            arrPhrases = arrPhrasesAll
            if !textFilter.isEmpty {
                arrPhrases = arrPhrases.filter { (scopeFilter == "Phrase" ? $0.PHRASE : $0.TRANSLATION).lowercased().contains(textFilter.lowercased()) }
            }
            if textbookFilter != 0 {
                arrPhrases = arrPhrases.filter { $0.TEXTBOOKID == textbookFilter }
            }
        } ~ rx.disposeBag

        reload().subscribe { _ in complete() } ~ rx.disposeBag
    }

    func reload() -> Single<()> {
        (inTextbook ? MUnitPhrase.getDataByTextbook(vmSettings.selectedTextbook, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO) : MUnitPhrase.getDataByLang(vmSettings.selectedTextbook.LANGID, arrTextbooks: vmSettings.arrTextbooks))
        .map { [unowned self] in
            arrPhrasesAll = $0
        }
    }

    static func update(_ id: Int, seqnum: Int) -> Single<()> {
        MUnitPhrase.update(id, seqnum: seqnum)
    }

    func update(item: MUnitPhrase) -> Single<()> {
        MUnitPhrase.update(item: item).flatMap { [unowned self] in
            MUnitPhrase.getDataById(item.ID, arrTextbooks: vmSettings.arrTextbooks)
        }.map {
            if let o = $0 { copyProperties(from: o, to: item) }
        }
    }

    func create(item: MUnitPhrase) -> Single<()> {
        MUnitPhrase.create(item: item).flatMap { [unowned self] in
            MUnitPhrase.getDataById($0, arrTextbooks: vmSettings.arrTextbooks)
        }.map { [unowned self] in
            if let o = $0 {
                arrPhrasesAll.append(o)
                copyProperties(from: o, to: item)
            }
        }
    }

    static func delete(item: MUnitPhrase) -> Single<()> {
        MUnitPhrase.delete(item: item)
    }

    func reindex(complete: @escaping (Int) -> Void) {
        for i in 1...arrPhrasesAll.count {
            let item = arrPhrasesAll[i - 1]
            guard item.SEQNUM != i else {continue}
            item.SEQNUM = i
            PhrasesUnitViewModel.update(item.ID, seqnum: item.SEQNUM).subscribe { _ in
                complete(i - 1)
            } ~ rx.disposeBag
        }
    }

    func newUnitPhrase() -> MUnitPhrase {
        MUnitPhrase().then {
            $0.LANGID = vmSettings.selectedLang.ID
            $0.TEXTBOOKID = vmSettings.USTEXTBOOK
            let maxElem = arrPhrasesAll.max{ ($0.UNIT, $0.PART, $0.SEQNUM) < ($1.UNIT, $1.PART, $1.SEQNUM) }
            $0.UNIT = maxElem?.UNIT ?? vmSettings.USUNITTO
            $0.PART = maxElem?.PART ?? vmSettings.USPARTTO
            $0.SEQNUM = (maxElem?.SEQNUM ?? 0) + 1
            $0.textbook = vmSettings.selectedTextbook
        }
    }

    func generateBlogContent() -> String {
        arrPhrasesAll.map { $0.UNIT }.unique.count > 1 ? "Error: Multiple Units" :
        Array(Dictionary(grouping: arrPhrasesAll) {
            $0.PART
        }.values).sorted {
            $0[0].PART < $1[0].PART
        }.map { arr in
            let s = arr.map { "* \($0.PHRASE)：\($0.TRANSLATION)：\n"}.joined(separator: "")
            return "\(arr[0].PARTSTR)\n\(s)"
        }.joined(separator: "")
    }
}
