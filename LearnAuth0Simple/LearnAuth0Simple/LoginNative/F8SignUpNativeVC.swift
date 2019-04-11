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
    
    @IBOutlet weak var firstNameSeparator: UIView!
    @IBOutlet weak var lastNameSeparator: UIView!
    @IBOutlet weak var emailOrUsernameSeparator: UIView!
    @IBOutlet weak var passwordSeparator: UIView!
    
    private var isNetworkAvailable: Bool? { return NetworkReachabilityManager()?.isReachable }
    private var isSignUpSuccessful: Bool = false
    private var refreshTimer: Timer?
    
    private var f8Auth0Manager = F8Auth0Manager.sharedInstance()!
    
    /// Login UI states, determined by three booleans
    typealias SignUpUIState = (isNetworkOn: Bool, isInfoValid: Bool, isSignUpSuccessful: Bool)
    private var loginUIState = (isNetworkOn: false, isInfoValid: false, isSignUpSuccessful: false)
    
    /// SignUp successful/failed notifier
    private lazy var signUpResultNotifier: F8SystemNotifier = {
        let view = F8SystemNotifier(titleText: "", bodyText: "", captionImage: UIImage(), withBlurBackground: true, resourceBundle: .main
        )
        return view
    }()
    
    
    /// No network notifier
    private lazy var noNetworkLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 22))
        //        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 0
        label.tintColor = F8ColorScheme.COLORTAG_COLOR_OPTION4
        label.textColor = F8ColorScheme.COLORTAG_COLOR_OPTION4
        label.textAlignment = .center
        label.text = F8LocaleStrings.noNetworkWarning.localized
        return label
    }()
    
    public override func viewDidLoad() {
        // Set self as the delegate for all textfields
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailOrUsernameTextField.delegate = self
        passwordTextField.delegate = self
        
        
        // Add login failed notifier and hide it
        view.addSubview(signUpResultNotifier)
        signUpResultNotifier.sizeAnchors == signUpResultNotifier.bounds.size
        signUpResultNotifier.centerAnchors == view.centerAnchors
        signUpResultNotifier.isHidden = true
        
        
        // Add no network notifier and hide it
        view.addSubview(noNetworkLabel)
        noNetworkLabel.center = logoImageView.center.applying(CGAffineTransform(translationX: 0, y: 50))
        noNetworkLabel.widthAnchor == view.widthAnchor - 16
        noNetworkLabel.centerXAnchor == view.centerXAnchor
        noNetworkLabel.topAnchor == logoImageView.bottomAnchor + 2
        noNetworkLabel.heightAnchor >= 20
        noNetworkLabel.bottomAnchor >= firstNameTextField.topAnchor - 20
        noNetworkLabel.isHidden = true
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        isSignUpSuccessful = false
        // Refresh the page and change UI basedon network
        refreshPage()
        // Start page refreshing timer
        refreshTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(refreshPage), userInfo: nil, repeats: true)
        
        firstNameTextField.text = "Foxx"
        lastNameTextField.text = "Conn"
        //        emailOrUsernameTextField.text = "jwang@ele.uri.edu"
        emailOrUsernameTextField.text = "jing.wang1986china@gmail.com"
        passwordTextField.text = "!1QazxsW2@"
        
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        refreshTimer?.invalidate()
        refreshTimer = nil
        clearForm()
    }
    
}


// Utils for Sign Up
extension F8SignUpNativeVC {
    
    
    private var isInfoValid: Bool {
        guard let emailOrUsernameString = emailOrUsernameTextField.text, let passwordString = passwordTextField.text, let firstNameString = firstNameTextField.text, let lastNameString = lastNameTextField.text else {
            return false
        }
        
        let isSpacesOnly = emailOrUsernameString.trimmingCharacters(in: .whitespaces).isEmpty || passwordString.trimmingCharacters(in: .whitespaces).isEmpty || firstNameString.trimmingCharacters(in: .whitespaces).isEmpty || lastNameString.trimmingCharacters(in: .whitespaces).isEmpty
        return !isSpacesOnly
    }
    
    
    @IBAction func onSignUpBtnTapped(_ sender: Any) {
        
        guard let firstNameString = firstNameTextField.text, let lastNameString = lastNameTextField.text, let emailOrUsernameString = emailOrUsernameTextField.text, let passwordString = passwordTextField.text else {
            F8Log.warn("Invalid sign up info from text fields!")
            return
        }
        
        
        let signUpCredential = F8SignUpCredential(firstName: firstNameString, lastName: lastNameString, emailOrUsername: emailOrUsernameString, password: passwordString)
        f8Auth0Manager.performSignUp(signUpCredential){[weak self] user, error in
            if error == nil {
                self?.signUpResultNotifier.blurButtonTappedHandler = self?.dismissNotifier
                self?.signUpResultNotifier.titleText = F8LocaleStrings.signedUpSuccessfullyTitle.localized
                self?.signUpResultNotifier.bodyText =  F8LocaleStrings.signedUpSuccessfullyBody.localized + "\n\((user?.email ?? ""))"
                self?.signUpResultNotifier.captionImage = UIImage(named: "checkMarkSmall")
                self?.signUpResultNotifier.captionImageTintColor = F8ColorScheme.COLORTAG_COLOR_OPTION2
                self?.signUpResultNotifier.isHidden = false
                self?.isSignUpSuccessful = true
            } else {
                self?.signUpResultNotifier.blurButtonTappedHandler = nil
                self?.signUpResultNotifier.titleText = F8LocaleStrings.signedUpFailedTitle.localized
                self?.signUpResultNotifier.bodyText = F8LocaleStrings.signedUpFailedBody.localized + "\n\((error?.localizedDescription ?? ""))"
                self?.signUpResultNotifier.captionImage = UIImage(named: "NoNetworkFilledFG")
                self?.signUpResultNotifier.isHidden = false
                self?.isSignUpSuccessful = false
                self?.delay(seconds: 2){
                    self?.signUpResultNotifier.isHidden = true
                }
                
            }
        }
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
        refreshPage()
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func dismissNotifier(_ sender: Any) {
        refreshPage()
        signUpResultNotifier.isHidden = true
        if isSignUpSuccessful { dismiss(animated: true, completion: nil) }
    }
    
    private func clearForm() {
        firstNameTextField.text = nil
        lastNameTextField.text = nil
        emailOrUsernameTextField.text = nil
        passwordTextField.text = nil
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

// Update page UI
extension F8SignUpNativeVC {
    /// Change the UI based on user login status and network availablility
    @objc private func refreshPage() {
        switchUIState(to: (isNetworkAvailable == true, isInfoValid, isSignUpSuccessful))
        
    }
    
    
    private func switchUIState(to state: SignUpUIState) {
        // (isNetworkOn: Bool, isInfoValid: Bool, isSignUpSuccessful: Bool)
        // Default state (true, false, false)
        
        // Enable all fields of the form
        // Textfields-Enable
        firstNameTextField.isEnabled = true
        lastNameTextField.isEnabled = true
        emailOrUsernameTextField.isEnabled = true
        passwordTextField.isEnabled = true
        // Textfields-Color
        firstNameTextField.textColor = F8ColorScheme.DEFAULT_BACKGROUND_NIGHT
        lastNameTextField.textColor = F8ColorScheme.DEFAULT_BACKGROUND_NIGHT
        emailOrUsernameTextField.textColor = F8ColorScheme.DEFAULT_BACKGROUND_NIGHT
        passwordTextField.textColor = F8ColorScheme.DEFAULT_BACKGROUND_NIGHT
        // Separators-Color
        firstNameSeparator.backgroundColor = F8ColorScheme.DEFAULT_BACKGROUND_NIGHT
        lastNameSeparator.backgroundColor = F8ColorScheme.DEFAULT_BACKGROUND_NIGHT
        emailOrUsernameSeparator.backgroundColor = F8ColorScheme.DEFAULT_BACKGROUND_NIGHT
        passwordSeparator.backgroundColor = F8ColorScheme.DEFAULT_BACKGROUND_NIGHT
        
        // Disable Sign Up button
        signUpBtn.isEnabled = false
        signUpBtn.backgroundColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
        signUpBtn.borderColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
        
        // Network is available
        logoImageView.image = UIImage(named: "appIconEnabled")
        noNetworkLabel.isHidden = true
        
        
        switch state {
        case (false, false, false):
            // Disable all fields of the form
            // Textfields-Enable
            firstNameTextField.isEnabled = false
            lastNameTextField.isEnabled = false
            emailOrUsernameTextField.isEnabled = false
            passwordTextField.isEnabled = false
            // Textfields-Color
            firstNameTextField.textColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            lastNameTextField.textColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            emailOrUsernameTextField.textColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            passwordTextField.textColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            // Separators-Color
            firstNameSeparator.backgroundColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            lastNameSeparator.backgroundColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            emailOrUsernameSeparator.backgroundColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            passwordSeparator.backgroundColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            
            // Network is not available
            logoImageView.image = UIImage(named: "appIconDisabled")
            noNetworkLabel.isHidden = false
            
        case (false, true, false):
            // Disable all fields of the form
            // Textfields-Enable
            firstNameTextField.isEnabled = false
            lastNameTextField.isEnabled = false
            emailOrUsernameTextField.isEnabled = false
            passwordTextField.isEnabled = false
            // Textfields-Color
            firstNameTextField.textColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            lastNameTextField.textColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            emailOrUsernameTextField.textColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            passwordTextField.textColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            // Separators-Color
            firstNameSeparator.backgroundColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            lastNameSeparator.backgroundColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            emailOrUsernameSeparator.backgroundColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            passwordSeparator.backgroundColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            
            // Network is not available
            logoImageView.image = UIImage(named: "appIconDisabled")
            noNetworkLabel.isHidden = false
            
        case (true, true, false):
            
            // Ready to sign up
            signUpBtn.isEnabled = true
            signUpBtn.backgroundColor = F8ColorScheme.DEFAULT_BACKGROUND_NIGHT
            signUpBtn.borderColor = F8ColorScheme.DEFAULT_BACKGROUND_NIGHT
            
            
        case (true, true, true):
            // Disable all fields of the form
            // Textfields-Enable
            firstNameTextField.isEnabled = false
            lastNameTextField.isEnabled = false
            emailOrUsernameTextField.isEnabled = false
            passwordTextField.isEnabled = false
            // Textfields-Color
            firstNameTextField.textColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            lastNameTextField.textColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            emailOrUsernameTextField.textColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            passwordTextField.textColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            // Separators-Color
            firstNameSeparator.backgroundColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            lastNameSeparator.backgroundColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            emailOrUsernameSeparator.backgroundColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            passwordSeparator.backgroundColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            
        case (true, false, false):
            break
        default:
            break
        }
    }
    
    
    
    override func keyboardWillAppear(note: Notification) {
        refreshTimer?.invalidate()
    }
    
    override func keyboardWillBeDisappear(note: Notification) {
        refreshPage()
        refreshTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(refreshPage), userInfo: nil, repeats: true)    }
    
}
