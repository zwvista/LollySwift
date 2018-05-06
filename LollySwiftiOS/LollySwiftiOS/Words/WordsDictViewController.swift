//
//  WordsDictViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import WebKit
import DropDown
import RxSwift

class WordsDictViewController: UIViewController {

    @IBOutlet weak var wvWordHolder: UIView!
    @IBOutlet weak var btnWord: UIButton!
    @IBOutlet weak var btnDict: UIButton!
    weak var wvWord: WKWebView!
    
    let vm = SearchViewModel(settings: vmSettings) {}
    let ddWord = DropDown(), ddDictOnline = DropDown()
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        wvWord = addWKWebView(webViewHolder: wvWordHolder)
        
        ddWord.anchorView = btnWord
        ddWord.dataSource = vm.arrWords
        ddWord.selectRow(vm.selectWordIndex)
        ddWord.selectionAction = { (index: Int, item: String) in
            self.vm.selectWordIndex = index
            self.selectWordChanged()
        }
        
        ddDictOnline.anchorView = btnDict
        ddDictOnline.dataSource = vm.vmSettings.arrDictsOnline.map { $0.DICTNAME! }
        ddDictOnline.selectRow(vm.vmSettings.selectedDictOnlineIndex)
        ddDictOnline.selectionAction = { (index: Int, item: String) in
            self.vm.vmSettings.selectedDictOnlineIndex = index
            self.vm.vmSettings.updateDictOnline().subscribe {
                self.selectDictChanged()
            }.disposed(by: self.disposeBag)
        }
        
        selectWordChanged()
    }
    
    private func selectWordChanged() {
        btnWord.setTitle(vm.selectWord, for: .normal)
        navigationItem.title = vm.selectWord
        selectDictChanged()
    }
    
    private func selectDictChanged() {
        let item = vmSettings.selectedDictOnline
        btnDict.setTitle(item.DICTNAME, for: .normal)
        let url = item.urlString(vm.selectWord)
        wvWord.load(URLRequest(url: URL(string: url)!))
    }
    
    
    @IBAction func showWordDropDown(_ sender: AnyObject) {
        ddWord.show()
    }
    
    @IBAction func showDictDropDown(_ sender: AnyObject) {
        ddDictOnline.show()
    }

}
