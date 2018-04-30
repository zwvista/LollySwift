//
//  UIView+ActivityIndicator.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2018/03/10.
//  Copyright © 2018年 趙 偉. All rights reserved.
//

import UIKit

// https://stackoverflow.com/questions/27960556/loading-an-overlay-when-running-long-tasks-in-ios/43570567
// https://codereview.stackexchange.com/questions/150300/showing-activity-indicator-loading-image-while-processing-in-background
extension UIView{
    func showBlurLoader(){
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.startAnimating()
        
        blurEffectView.contentView.addSubview(activityIndicator)
        activityIndicator.center = blurEffectView.contentView.center
        
        self.addSubview(blurEffectView)
        UIApplication.shared.beginIgnoringInteractionEvents();
    }
    
    func removeBlurLoader(){
        self.subviews.compactMap {  $0 as? UIVisualEffectView }.forEach {
            $0.removeFromSuperview()
        }
        UIApplication.shared.endIgnoringInteractionEvents();
    }
}
