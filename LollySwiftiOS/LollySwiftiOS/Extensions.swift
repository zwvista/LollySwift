//
//  Extensions.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2018/03/27.
//  Copyright © 2018年 趙 偉. All rights reserved.
//

import Foundation
import WebKit
import DropDown

extension UIViewController {
    func yesNoAction(title: String?, message: String?, yesHandler: @escaping (UIAlertAction) -> (), noHandler: @escaping (UIAlertAction) -> ()) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: noHandler)
        alertController.addAction(noAction)
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: yesHandler)
        alertController.addAction(yesAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // https://stackoverflow.com/questions/46793618/ios-wkwebview-vs-uiwebview?rq=1
    func addWKWebView(webViewHolder: UIView) -> WKWebView {
        let wkWebView: WKWebView = {
            let v = WKWebView()
            v.translatesAutoresizingMaskIntoConstraints = false
            return v
        }()
        // add the WKWebView to the "holder" UIView
        webViewHolder.addSubview(wkWebView)
        
        // pin to all 4 edges
        wkWebView.topAnchor.constraint(equalTo: webViewHolder.topAnchor, constant: 0.0).isActive = true
        wkWebView.bottomAnchor.constraint(equalTo: webViewHolder.bottomAnchor, constant: 0.0).isActive = true
        wkWebView.leadingAnchor.constraint(equalTo: webViewHolder.leadingAnchor, constant: 0.0).isActive = true
        wkWebView.trailingAnchor.constraint(equalTo: webViewHolder.trailingAnchor, constant: 0.0).isActive = true
        return wkWebView
    }
}

extension DropDown {
    func selectIndex(_ index: Int) {
        clearSelection()
        selectRow(index)
    }
}
