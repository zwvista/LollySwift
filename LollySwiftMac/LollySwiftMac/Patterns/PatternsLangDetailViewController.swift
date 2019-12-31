//
//  PatternsLangDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/01/01.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

class PatternsLangDetailViewController: NSViewController {
    
    var vm: PatternsLangViewModel!
    var complete: (() -> Void)?
    var item: MLangPattern!
    var isAdd: Bool!

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfPattern: NSTextField!
    @IBOutlet weak var tfNote: NSTextField!

    let disposeBag = DisposeBag()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
