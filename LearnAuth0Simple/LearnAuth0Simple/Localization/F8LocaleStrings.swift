//
//  F8LocaleStrings.swift
//  loggerApp
//
//  Created by Jing Wang on 1/22/19.
//  Copyright © 2019 figur8. All rights reserved.
//

import UIKit

public enum F8LocaleStrings: String, F8Localizable, CaseIterable {
    
    // For f8 Login page
    case signIn
    case signOut
    case continueText
    case continueOffline
    case whenOffline
    case offlineNoNetwork
    case loginFailedText
    case noNetworkWarning
    case loginErrorText
    
    // For f8 Sign up page
    case signedUpSuccessfullyTitle
    case signedUpSuccessfullyBody
    case signedUpFailedTitle
    case signedUpFailedBody
    
    // For f8 Reset password page
    case resetPWText
    
    // f8 Info page
    case otherActivity
    case otherTrainee
    //    case continueNext
    case doneText
    case addTraineeText
    
    // For f8 Pairing page
    case gyroCalibMsgTitle
    case gyroCalibMsgBody
    case ignoreText
    case retryText
    case optimizingText
    case errOptimizingMsg
    case aMomentMsg
    case bleResetingMsg
    case skipText
    
    // f8 Recorder page
    case testNamePlaceholder
    case notesNamePlaceholder
    case noDeviceConnected
    case trialsText
    case startCollectingData
    case magDeclinationNote
    case plotLengendNotApply
    case plotLengendNotAssign
    
    case alertSavedError
    case alertOK
    case alertSavedOk
    case alertPhotoSavedToAlbum
    case alertSave
    case alertInputMagIncl
    case alertInputHeading
    case alertCollectAngle
    case figur8
    case alertDelete
    case inputNameAlertTitle
    
    // For f8 file list page
    //    case trialsText
    case selectText
    case selectTrialsText
    case cancelText
    case confirmDeletionMsg // Pluralization is handled in .stringsdict files
    case deleteText
    case deleteTrialsText
    case activityCenterAlertMsg
    case noticeText
    
    
    
    // F8Device or similar
    case photoAudioNotAuthorized
    case deviceDisconnected
    
    // For Utils
    case okText
    case errorText
    case confirmText

    
    public var tableName: String {
        return "Localizable"
    }
    
    public var tableBundle: Bundle {
        return Bundle.main
    }
}
