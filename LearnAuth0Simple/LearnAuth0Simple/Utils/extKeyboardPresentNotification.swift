//
//  extKeyboardPresentNotification.swift
//  LearnAuth0Simple
//
//  Created by Jing Wang on 4/9/19.
//  Copyright © 2019 figur8 Inc. All rights reserved.
//

import UIKit

extension UIViewController {
    func registerKeyboardNotifications() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillAppear(note:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillBeDisappear(note:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    @objc func keyboardWillAppear(note: Notification) {}
    
    @objc func keyboardWillBeDisappear(note: Notification) {}
    
}
