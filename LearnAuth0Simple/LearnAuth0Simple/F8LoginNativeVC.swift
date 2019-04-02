//
//  F8LoginNativeVC.swift
//  loggerApp
//
//  Created by Jing Wang on 3/13/19.
//  Copyright © 2019 figur8. All rights reserved.
//

import UIKit
import Auth0
import SimpleKeychain
import Anchorage
import Alamofire
//import F8SDK

public class F8LoginNativeVC: UIViewController {
    
    // MARK: - Properties
    private let screenSize = UIScreen.main.bounds
    private let utils = Utils.sharedInstance
    
    @IBOutlet weak var logoImageView: UIImageView!
    //    @IBOutlet weak var userProfileImageView: UIImageView!
    
    @IBOutlet weak var signInBtn: UILocalizedButton!
    @IBOutlet weak var continueBtn: UILocalizedButton!
    
    
    @IBOutlet weak var emailOrUsernameTextField: UITextField!
    @IBOutlet weak var emailOrUsernameSeparator: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordSeparator: UIView!
    @IBOutlet weak var loginSpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var resetPasswordBtn: UILocalizedButton!
    @IBOutlet weak var signupNewUserBtn: UILocalizedButton!
    @IBOutlet weak var needAnAccountLabel: UILocalizedLabel!
    
    
    private var isNetworkAvailable: Bool? { return NetworkReachabilityManager()?.isReachable }
    private var isUserLoggedIn: Bool = false // { return isUserSignedIn()}
    private var refreshTimer: Timer?
    
    private var f8Auth0Manager = F8Auth0Manager.sharedInstance()!
    
    
    // Offline indicator (cloud with a stop)
    private lazy var offlineIndicator: UIImageView = {
        let xPos = UIScreen.main.bounds.width*0.68
        let imageView = UIImageView(frame: CGRect(x: xPos , y: 30, width: 26, height: 26))
        imageView.image = UIImage(named: "Offline", in: Bundle.main, compatibleWith: nil)
        imageView.tintColor = F8ColorScheme.COLORTAG_COLOR_OPTION4
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    private var retrievedCredentials: Credentials?
    private var loading: Bool = false
    
    private var isUIDebug: Bool = false
    
    /// Login UI states, determined by three booleans
    typealias F8LoginUIState = (isNetworkOn: Bool, isLoggedIn: Bool, isInfoValid: Bool)
    private var loginUIState = (isNetworkOn: false, isLoggedIn: false, isInfoValid: false)
    
    /// Login failed notifier
    private lazy var loginFailedNotifier: F8SystemNotifier = {
        let view = F8SystemNotifier(titleText: F8LocaleStrings.loginFailedText.localized, bodyText: F8LocaleStrings.loginErrorText.localized, captionImage: UIImage(named: "NoNetworkFilledFG"), withBlurBackground: true, resourceBundle: .main
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
        // Set up the style for navigation controller
        self.navigationController?.configure()
        
        // Set self at the delegate for both textfields
        emailOrUsernameTextField.delegate = self
        passwordTextField.delegate = self
        
        //        emailOrUsernameTextField.textContentType = .emailAddress
        //        passwordTextField.textContentType = .password
        
        
        // Add login failed notifier and hide it
        view.addSubview(loginFailedNotifier)
        loginFailedNotifier.sizeAnchors == loginFailedNotifier.bounds.size
        loginFailedNotifier.centerAnchors == view.centerAnchors
        loginFailedNotifier.isHidden = true
        
        // Add no network notifier and hide it
        view.addSubview(noNetworkLabel)
        noNetworkLabel.center = logoImageView.center.applying(CGAffineTransform(translationX: 0, y: 50))
        noNetworkLabel.widthAnchor == view.widthAnchor - 16
        noNetworkLabel.centerXAnchor == view.centerXAnchor
        noNetworkLabel.topAnchor == logoImageView.bottomAnchor + 10
        noNetworkLabel.heightAnchor >= 20
        noNetworkLabel.bottomAnchor >= emailOrUsernameTextField.topAnchor - 20
        noNetworkLabel.isHidden = true
        
        /// Disable debuging+developing effect
        if !isUIDebug {
            signInBtn.backgroundColor = F8ColorScheme.DEFAULT_BACKGROUND_NIGHT
            continueBtn.backgroundColor = F8ColorScheme.DEFAULT_BACKGROUND_DAY
            loginSpinner.backgroundColor = F8ColorScheme.DEFAULT_CLEAR
        }
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        // Hide global cloudUnavailable indicator
        offlineIndicator.isHidden = true
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

/// Utilities for signIn/signOut/signUp/reset
extension F8LoginNativeVC {
    
    fileprivate var isInfoValid: Bool {
        guard let emailOrUsernameText = emailOrUsernameTextField.text, let passwordText = passwordTextField.text else {
            return false
        }
        
        let isSpacesOnly = emailOrUsernameText.trimmingCharacters(in: .whitespaces).isEmpty || passwordText.trimmingCharacters(in: .whitespaces).isEmpty
        return !isSpacesOnly
    }
    
    
    @IBAction func onSignInOutTapped(_ sender: Any) {
        
        if isUserLoggedIn {
            // Sign Out
            f8Auth0Manager.logout()
            isUserLoggedIn = false
            emailOrUsernameTextField.text = nil
            passwordTextField.text = nil
            refreshPage()
        } else {
            // Sign In
            
            // Get email/username and password
            guard var emailOrUsernameString = emailOrUsernameTextField.text, var passwordString = passwordTextField.text else {
                F8Log.info("Invalid login infomation!")
                return
            }
            // Remove white spaces, case in-sensitive
            emailOrUsernameString = emailOrUsernameString.trimmingCharacters(in: .whitespaces).lowercased()
            // Remove white spaces, case sensitive
            passwordString = passwordString.trimmingCharacters(in: .whitespaces)
            
            self.view.endEditing(true)
            self.loading = true
            
            if self.f8Auth0Manager.isRegistered && isNetworkAvailable == true && isInfoValid {
                self.f8Auth0Manager.performLoginWith(usernameOrEmail: emailOrUsernameString, password: passwordString) { [weak self] in
                    self?.loading = false
                    switch $0 {
                    case .failure(let error):
                        F8Log.warn(error)
                        DispatchQueue.main.async {
                            // Show login failed notifier
                            self?.loginFailedNotifier.bodyText = "\(error.localizedDescription)"
                            self?.loginFailedNotifier.isHidden = false
                            self?.delay(seconds: 2){
                                self?.loginFailedNotifier.isHidden = true
                            }
                        }
                    case .success(let credentials):
                        if credentials.accessToken != nil {
                            self?.isUserLoggedIn = true
                            self?.refreshPage()
                        }
                    }
                }
                
            }
            
        }
        
    }
    
    
    @IBAction func onForgotPasswordBtnTapped(_ sender: Any) {
        resetPassword()
    }
    
    @IBAction func onSignupBtnTapped(_ sender: Any) {
        signupNewUser()
    }
    
    
    private func resetPassword() {
        F8Log.info("Trying to reset password!")
    }
    
    private func signupNewUser() {
        F8Log.info("Trying to sign up new user!")
    }
    
    
}



/// Utilities for navigation
extension F8LoginNativeVC {
    
    @IBAction func onContinueTapped(_ sender: Any) {
        navToNextPage()
        // Hide/Show cloudUnavailable icon by checking the status of 'isUserLoggedIn'
        offlineIndicator.tintColor = isNetworkAvailable == true ? F8ColorScheme.NOTSELECTED_BUTTON_TITLE : F8ColorScheme.LOGO_SCHEME_V1
        offlineIndicator.isHidden = isUserLoggedIn
        
    }
    
    /// Navigates to the next page
    private func navToNextPage(){
//        if self.navigationController?.topViewController != F8LoggerConfig.shared.f8LoginNative.postViewController {
//            self.navigationController?.pushViewController(F8LoggerConfig.shared.f8LoginNative.postViewController!, animated: true)
//        }
    }
    
}


extension F8LoginNativeVC: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.emailOrUsernameTextField:
            //            self.passwordTextField.becomeFirstResponder()
            emailOrUsernameTextField.resignFirstResponder()
        case self.passwordTextField:
            //        case self.passwordTextField where self.isInfoValid:
            passwordTextField.resignFirstResponder()
        //            self.performLogin()
        default:
            break
        }
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        F8Log.info("Function to be completed per request!")
    }
}


// Update page UI
extension F8LoginNativeVC {
    /// Change the UI based on user login status and network availablility
    @objc private func refreshPage() {
        switchUIState(to: (isNetworkAvailable == true, isUserLoggedIn, isInfoValid))
    }
    
    /// Switch UI states of login page to a specific state
    // Call this funcion, after (not before) the UI state of login page has changed
    // The idea is that reset all the states to state (true, false, true), i.e.
    // Has network,not login yet, user info is valid, then just touch the UI that need
    // to change under that specific UI state
    
    private func switchUIState(to state: F8LoginUIState) {
        
        emailOrUsernameTextField.isEnabled = true
        passwordTextField.isEnabled = true
        emailOrUsernameTextField.textColor = F8ColorScheme.DEFAULT_BACKGROUND_NIGHT
        passwordTextField.textColor = F8ColorScheme.DEFAULT_BACKGROUND_NIGHT
        passwordSeparator.backgroundColor = F8ColorScheme.DEFAULT_SUBTITLE_TEXT_ENABLED
        emailOrUsernameSeparator.backgroundColor = F8ColorScheme.DEFAULT_SUBTITLE_TEXT_ENABLED
        
        signInBtn.isEnabled = true
        signInBtn.setTitle(F8LocaleStrings.signIn.localized, for: .normal)
        signInBtn.backgroundColor = F8ColorScheme.DEFAULT_BACKGROUND_NIGHT
        signInBtn.borderColor = F8ColorScheme.DEFAULT_BACKGROUND_NIGHT
        
        continueBtn.isEnabled = true
        continueBtn.setTitle(F8LocaleStrings.continueOffline.localized, for: .normal)
        noNetworkLabel.isHidden = true
        logoImageView.image = UIImage(named: "appIconEnabled", in: Bundle.main, compatibleWith: nil)
        offlineIndicator.isHidden = false
        
        //                // TODO: In dev, disable them for now
        //                resetPasswordBtn.isHidden = false
        //                signupNewUserBtn.isHidden = false
        //                needAnAccountLabel.isHidden = false
        
        // For dev only
        resetPasswordBtn.isHidden = true
        signupNewUserBtn.isHidden = true
        needAnAccountLabel.isHidden = true
        
        
        continueBtn.isHidden = false
        
        resetPasswordBtn.isEnabled = true
        signupNewUserBtn.isEnabled = true
        
        
        switch state {
        // No network, no login, invalid info, page is loaded for the first time
        case (false, false, false):
            noNetworkLabel.isHidden = false
            signInBtn.isEnabled = false
            signInBtn.backgroundColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            signInBtn.borderColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            logoImageView.image = UIImage(named: "appIconDisabled", in: Bundle.main, compatibleWith: nil)
            emailOrUsernameTextField.isEnabled = false
            passwordTextField.isEnabled = false
            passwordSeparator.backgroundColor = F8ColorScheme.DEFAULT_SUBTITLE_TEXT_DISABLED
            emailOrUsernameSeparator.backgroundColor = F8ColorScheme.DEFAULT_SUBTITLE_TEXT_DISABLED
            
            resetPasswordBtn.isEnabled = false
            signupNewUserBtn.isEnabled = false
            
        // No network, no login, valid info
        case (false, false, true):
            noNetworkLabel.isHidden = false
            
            signInBtn.isEnabled = false
            signInBtn.backgroundColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            signInBtn.borderColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            
            logoImageView.image = UIImage(named: "appIconDisabled", in: Bundle.main, compatibleWith: nil)
            emailOrUsernameTextField.isEnabled = false
            passwordTextField.isEnabled = false
            passwordSeparator.backgroundColor = F8ColorScheme.DEFAULT_SUBTITLE_TEXT_DISABLED
            emailOrUsernameSeparator.backgroundColor = F8ColorScheme.DEFAULT_SUBTITLE_TEXT_DISABLED
            
            resetPasswordBtn.isEnabled = false
            signupNewUserBtn.isEnabled = false
            
        // Has network, has login, valid info
        case (true, true, true):
            // Lock credential input fields
            emailOrUsernameTextField.isEnabled = false
            passwordTextField.isEnabled = false
            emailOrUsernameTextField.textColor = F8ColorScheme.DEFAULT_SUBTITLE_TEXT_DISABLED
            passwordTextField.textColor = F8ColorScheme.DEFAULT_SUBTITLE_TEXT_DISABLED
            passwordSeparator.backgroundColor = F8ColorScheme.DEFAULT_SUBTITLE_TEXT_DISABLED
            emailOrUsernameSeparator.backgroundColor = F8ColorScheme.DEFAULT_SUBTITLE_TEXT_DISABLED
            
            offlineIndicator.isHidden = true
            signInBtn.setTitle(F8LocaleStrings.signOut.localized, for: .normal)
            continueBtn.setTitle(F8LocaleStrings.continueText.localized, for: .normal)
            resetPasswordBtn.isHidden = true
            signupNewUserBtn.isHidden = true
            needAnAccountLabel.isHidden = true
            
        // Has network, no login, invalid info, page is loaded for the first time
        case (true, false, false):
            signInBtn.isEnabled = false
            signInBtn.backgroundColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            signInBtn.borderColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            
        // Has network, no login, valid info
        case (true, false, true):
            break
        default:
            F8Log.error("Please check the logic for UI of F8 login page")
        }
        
    }
}