//
//  UINavigationControllerExtension.swift
//  F8SDK
//
//  Created by Keith Desrosiers on 10/3/17.
//  Copyright © 2017 figur8. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    /// Extension to the navigation controllers to configure them for our use
    public func configure() {
        
        self.navigationBar.isHidden = false
        
        // Opaque
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.navigationBar.barTintColor = F8ColorScheme.DEFAULT_BACKGROUND_DAY
        self.navigationBar.tintColor = F8ColorScheme.DEFAULT_BACKGROUND_NIGHT
        navigationController?.toolbar.tintColor = F8ColorScheme.DEFAULT_BACKGROUND_NIGHT
        let backItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backItem
    }
    
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.filter({$0.isKind(of: ofClass)}).last {
            popToViewController(vc, animated: animated)
        }
    }
    
}
