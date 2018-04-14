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

class WordsDictViewController: UIViewController {

    @IBOutlet weak var wvWordHolder: UIView!
    @IBOutlet weak var btnWord: UIButton!
    @IBOutlet weak var btnDict: UIButton!
    weak var wvWord: WKWebView!
    
    let vm = SearchViewModel(settings: vmSettings) {}
    let ddWord = DropDown(), ddDict = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        wvWord = addWKWebView(webViewHolder: wvWordHolder)
        
        ddWord.anchorView = btnWord
        ddWord.dataSource = vm.arrWords.map { $0.WORDNOTE }
        ddWord.selectRow(vm.selectWordIndex)
        ddWord.selectionAction = { [unowned self] (index: Int, item: String) in
            self.vm.selectWordIndex = index
            self.selectWordChanged()
        }
        
        ddDict.anchorView = btnDict
        ddDict.dataSource = vm.vmSettings.arrDictionaries.map { $0.DICTNAME! }
        ddDict.selectRow(vm.vmSettings.selectedDictIndex)
        ddDict.selectionAction = { [unowned self] (index: Int, item: String) in
            self.vm.vmSettings.selectedDictIndex = index
            self.vm.vmSettings.updateDict {
                self.selectDictChanged()
            }
        }
        
        selectWordChanged()
    }
    
    private func selectWordChanged() {
        btnWord.setTitle(vm.selectWord.WORDNOTE, for: .normal)
        navigationItem.title = vm.selectWord.WORD
        selectDictChanged()
    }
    
    private func selectDictChanged() {
        let m = vmSettings.selectedDict
        btnDict.setTitle(m.DICTNAME, for: .normal)
        let url = m.urlString(vm.selectWord.WORD)
        wvWord.load(URLRequest(url: URL(string: url)!))
    }
    
    
    @IBAction func showWordDropDown(_ sender: AnyObject) {
        ddWord.show()
    }
    
    @IBAction func showDictDropDown(_ sender: AnyObject) {
        ddDict.show()
    }

}
