//
//  KeyboardPresentNotificationProtocol.swift
//  LearnAuth0Simple
//
//  Created by Jing Wang on 4/9/19.
//  Copyright © 2019 figur8 Inc. All rights reserved.
//

import Foundation

protocol KeyboardPresentNotificationProtocol {
    
    func registerKeyboardNotifications()
    
    func removeKeyboardNotifications()
    
    func keyboardWillAppear(note: Notification)
    
    func keyboardWillBeDisappear(note: Notification)
}
