//
//  F8ResetPWNativeVC.swift
//  LearnAuth0Simple
//
//  Created by Jing Wang on 4/10/19.
//  Copyright © 2019 figur8 Inc. All rights reserved.
//

import UIKit
import Alamofire
import Anchorage

public class F8ResetPWNativeVC: UIViewController {
    
    @IBOutlet weak var emailTexfield: UITextField!
    @IBOutlet weak var emailSeparator: UIView!
    @IBOutlet weak var resetPWBtn: UILocalizedButton!
    @IBOutlet weak var logoImageView: UIImageView!
    
    private var isNetworkAvailable: Bool? { return NetworkReachabilityManager()?.isReachable }
    private var isResetSuccessful: Bool = false
    private var f8Auth0Manager = F8Auth0Manager.sharedInstance()!
    
    private var refreshTimer: Timer?
    
    private var isUIDebug: Bool = false
    
    /// Reset password UI states, determined by two booleans
    typealias F8ResetPWUIState = (isNetworkOn: Bool, isInfoValid: Bool)
    private var resetPWUIState = (isNetworkOn: false, isInfoValid: false)
    
    /// Reset password successful/failed notifier
    private lazy var resetPWResultNotifier: F8SystemNotifier = {
        let view = F8SystemNotifier(titleText: "", bodyText: "", captionImage: UIImage(), withBlurBackground: true, resourceBundle: .main
        )
        return view
    }()
    
    /// No network notifier
    private lazy var noNetworkLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 22))
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 0
        label.tintColor = F8ColorScheme.COLORTAG_COLOR_OPTION4
        label.textColor = F8ColorScheme.COLORTAG_COLOR_OPTION4
        label.textAlignment = .center
        label.text = F8LocaleStrings.noNetworkWarning.localized
        return label
    }()
    
    
    public override func viewDidLoad() {
        
        // Set textfield delegate
        emailTexfield.delegate = self
        
        // Add login failed notifier and hide it
        view.addSubview(resetPWResultNotifier)
        resetPWResultNotifier.sizeAnchors == resetPWResultNotifier.bounds.size
        resetPWResultNotifier.centerAnchors == view.centerAnchors
        resetPWResultNotifier.isHidden = true
        
        
        // Add no network notifier and hide it
        view.addSubview(noNetworkLabel)
        noNetworkLabel.center = logoImageView.center.applying(CGAffineTransform(translationX: 0, y: 50))
        noNetworkLabel.widthAnchor == view.widthAnchor - 16
        noNetworkLabel.centerXAnchor == view.centerXAnchor
        noNetworkLabel.topAnchor == logoImageView.bottomAnchor + 2
        noNetworkLabel.heightAnchor >= 20
        noNetworkLabel.bottomAnchor >= emailTexfield.topAnchor - 20
        noNetworkLabel.isHidden = true
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        isResetSuccessful = false
        // Refresh the page and change UI basedon network
        refreshPage()
        // Start page refreshing timer
        refreshTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(refreshPage), userInfo: nil, repeats: true)
        registerKeyboardNotifications()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        refreshTimer?.invalidate()
        refreshTimer = nil
        removeKeyboardNotifications()
        clearForm()
    }
}

// Utils: Navigation
extension F8ResetPWNativeVC {
    func clearForm() {
        emailTexfield.text = nil
    }
    
    @IBAction func onDimissBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissNotifier(_ sender: Any) {
        refreshPage()
        resetPWResultNotifier.isHidden = true
    }
    
}

// Utils: Reset password 
extension F8ResetPWNativeVC {
    
    @IBAction func onResetPWBtnTapped(_ sender:Any) {
        
        guard let emailString = emailTexfield.text else { return }
        f8Auth0Manager.resetPassword(email: emailString) {[weak self] error in
            self?.resetPWResultNotifier.titleText = "Reset Password"
            if error == nil {
                self?.resetPWResultNotifier.bodyText = "Email for reseting has been sent to your email!\n\(emailString)"
                self?.resetPWResultNotifier.captionImage = UIImage(named: "checkMarkSmall")
                self?.resetPWResultNotifier.captionImageTintColor = F8ColorScheme.COLORTAG_COLOR_OPTION2
            } else {
                self?.resetPWResultNotifier.bodyText = "Please check your email!\n\(emailString)"
                self?.resetPWResultNotifier.captionImage = UIImage(named: "NoNetworkFilledFG")
            }
            self?.resetPWResultNotifier.isHidden = false
            self?.resetPWResultNotifier.blurButtonTappedHandler = self?.dismissNotifier
            
        }
    }
    
    private var isInfoValid: Bool {
        guard let emailString = emailTexfield.text else {
            return false
        }
        let isSpacesOnly = emailString.trimmingCharacters(in: .whitespaces).isEmpty
        return !isSpacesOnly
    }
    
}


// Utils: Textfield handling
extension F8ResetPWNativeVC: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

// Utils: Page refresh
extension F8ResetPWNativeVC {
    
    @objc func refreshPage() {
        switchUIState(to: (isNetworkAvailable == true, isInfoValid))
    }
    
    
    func switchUIState(to state: F8ResetPWUIState) {
        emailTexfield.isEnabled = true
        emailTexfield.textColor = F8ColorScheme.DEFAULT_BACKGROUND_NIGHT
        emailSeparator.backgroundColor = F8ColorScheme.DEFAULT_BACKGROUND_NIGHT
        
        resetPWBtn.isEnabled = false
        resetPWBtn.backgroundColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
        resetPWBtn.borderColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
        
        noNetworkLabel.isHidden = true
        
        
        switch state {
        case (false, false):
            emailTexfield.isEnabled = false
            emailTexfield.textColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            emailSeparator.backgroundColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            noNetworkLabel.isHidden = false
        case (false, true):
            emailTexfield.isEnabled = false
            emailTexfield.textColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            emailSeparator.backgroundColor = F8ColorScheme.DEFAULT_TITLE_TEXT_DISABLED
            noNetworkLabel.isHidden = false
        case (true, true):
            resetPWBtn.isEnabled = true
            resetPWBtn.backgroundColor = F8ColorScheme.DEFAULT_BACKGROUND_NIGHT
            resetPWBtn.borderColor = F8ColorScheme.DEFAULT_BACKGROUND_NIGHT
        case (true, false):
            break
        }
    }
    
    // Stop page refreshing when key board is presented
    override func keyboardWillAppear(note: Notification) {
        refreshTimer?.invalidate()
    }
    
    // Resume page refreshing when key board is dismissed
    override func keyboardWillBeDisappear(note: Notification) {
        refreshPage()
        refreshTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(refreshPage), userInfo: nil, repeats: true)    }
}



