//
//  F8SignUpNativeVC.swift
//  LearnAuth0Simple
//
//  Created by Jing Wang on 4/5/19.
//  Copyright © 2019 figur8 Inc. All rights reserved.
//

import UIKit
import Alamofire
import Anchorage

public class F8SignUpNativeVC: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailOrUsernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpBtn: UILocalizedButton!
    @IBOutlet weak var logoImageView: UIImageView!
    
    private var isNetworkAvailable: Bool? { return NetworkReachabilityManager()?.isReachable }
    private var isSignUpSuccessful: Bool = false
    private var refreshTimer: Timer?
    
    private var f8Auth0Manager = F8Auth0Manager.sharedInstance()!
    
    /// Login UI states, determined by three booleans
    typealias SignUpUIState = (isNetworkOn: Bool, isInfoValid: Bool, isSignUpSuccessful: Bool)
    private var loginUIState = (isNetworkOn: false, isInfoValid: false, isSignUpSuccessful: false)
    
    
    public override func viewDidLoad() {
        // Set self as the delegate for all textfields
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailOrUsernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        // Refresh the page and change UI basedon network
        refreshPage()
        // Start page refreshing timer
        refreshTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(refreshPage), userInfo: nil, repeats: true)
        
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
}

// Update page UI
extension F8SignUpNativeVC {
    /// Change the UI based on user login status and network availablility
    @objc private func refreshPage() {
        switchUIState(to: (isNetworkAvailable == true, isInfoValid, isSignUpSuccessful))
        
    }
    
    
    private func switchUIState(to state: SignUpUIState) {
        // (isNetworkOn: Bool, isInfoValid: Bool, isSignUpSuccessful: Bool)
        // Default state (true, false, false)
        
        firstNameTextField.isEnabled = true
        lastNameTextField.isEnabled = true
        emailOrUsernameTextField.isEnabled = true
        passwordTextField.isEnabled = true
        
        signUpBtn.isEnabled = true
        
        switch state {
        case (false, false, false):
            firstNameTextField.isEnabled = false
            lastNameTextField.isEnabled = false
            emailOrUsernameTextField.isEnabled = false
            passwordTextField.isEnabled = false
            signUpBtn.isEnabled = true

        case (false, true, false):
            firstNameTextField.isEnabled = false
            lastNameTextField.isEnabled = false
            emailOrUsernameTextField.isEnabled = false
            passwordTextField.isEnabled = false
            
        case (true, true, false):
            break
        case (true, true, true):
            
            break
        case (true, false, false):
            signUpBtn.isEnabled = false

            break
        default:
            break
        }
    }
    
    
}


// Utils for Sign Up
extension F8SignUpNativeVC {
    
    
    private var isInfoValid: Bool {
        guard let emailOrUsernameText = emailOrUsernameTextField.text, let passwordText = passwordTextField.text else {
            return false
        }
        
        let isSpacesOnly = emailOrUsernameText.trimmingCharacters(in: .whitespaces).isEmpty || passwordText.trimmingCharacters(in: .whitespaces).isEmpty
        return !isSpacesOnly
    }
    
    
    @IBAction func onSignUpBtnTapped(_ sender: Any) {

    }
    
}


/// Utilities for navigation
extension F8SignUpNativeVC {
    
    @IBAction func onContinueTapped(_ sender: Any) {
        navToNextPage()
    }
    
    /// Navigates to the next page
    private func navToNextPage(){
        //        if self.navigationController?.topViewController != F8LoggerConfig.shared.f8LoginNative.postViewController {
        //            self.navigationController?.pushViewController(F8LoggerConfig.shared.f8LoginNative.postViewController!, animated: true)
        //        }
    }
    
    @IBAction func onDismissBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
}


extension F8SignUpNativeVC: UITextFieldDelegate {

    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        F8Log.info("Delegate being called")
        switch textField {
        case firstNameTextField:
            lastNameTextField.becomeFirstResponder()
        case lastNameTextField:
            emailOrUsernameTextField.becomeFirstResponder()
        case emailOrUsernameTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            passwordTextField.resignFirstResponder()
        default:
            break
        }
        refreshPage()
        return true
    }
    
    
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        F8Log.info("Start editing!")        
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        F8Log.info("End editing!")
    }
}
