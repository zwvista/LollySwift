//
//  WordsDictViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import WebKit

class WordsDictViewController: UIViewController, MKDropdownMenuDataSource, MKDropdownMenuDelegate {

    @IBOutlet weak var wvWordHolder: UIView!
    @IBOutlet weak var mkDropDownMenu: MKDropdownMenu!

    weak var wvWord: WKWebView!
    let vm = SearchViewModel(settings: vmSettings) {}

    override func viewDidLoad() {
        super.viewDidLoad()
        wvWord = addWKWebView(webViewHolder: wvWordHolder)
        selectWordChanged(reload: false)
    }
    
    private func selectWordChanged(reload: Bool) {
        navigationItem.title = vm.selectWord
        selectDictChanged()
        if reload { mkDropDownMenu.reloadComponent(0) }
    }
    
    private func selectDictChanged() {
        let m = vmSettings.selectedDict
        let url = m.urlString(vm.selectWord)
        wvWord.load(URLRequest(url: URL(string: url)!))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mkDropDownMenu.closeAllComponents(animated: true)
    }

    func numberOfComponents(in dropdownMenu: MKDropdownMenu) -> Int {
        return 2
    }
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return vm.arrWords.count
        case 1:
            return vm.vmSettings.arrDictionaries.count
        default:
            return 0
        }
    }
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, widthForComponent component: Int) -> CGFloat {
        return dropdownMenu.bounds.width / 2
    }
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, titleForComponent component: Int) -> String? {
        switch component {
        case 0:
            return vm.selectWord
        case 1:
            return vm.vmSettings.selectedDict.DICTNAME
        default:
            return nil
        }
    }
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return vm.arrWords[row].WORD
        case 1:
            return vm.vmSettings.arrDictionaries[row].DICTNAME
        default:
            return nil
        }
    }
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            vm.selectWord = vm.arrWords[row].WORD
            selectWordChanged(reload: true)
        case 1:
            vm.vmSettings.selectedDictIndex = row
            vm.vmSettings.updateDict {
                self.selectDictChanged()
                dropdownMenu.reloadComponent(1)
            }
        default:
            break
        }
        dropdownMenu.closeAllComponents(animated: true)
    }
}
