//
//  F8Settings.swift
//  loggerApp-Dev
//
//  Created by Keith Desrosiers on 8/1/18.
//  Copyright © 2018 figur8. All rights reserved.
//

import Foundation
import SimpleKeychain

public struct F8LoginCredential: Codable {
    public var emailOrUsername: String
    public var passowrd: String
    
    public init(emailOrusername: String, password: String) {
        self.emailOrUsername = emailOrusername
        self.passowrd = password
    }
}


public enum F8LoginCredentialsError: Error {
    case noLoginCredentials(String)
    case noNetwork
    case failedDecode(Error)
//    case noRefreshToken
//    case failedRefresh(Error)
//    case touchFailed(Error)
}

public class F8AppUtils {
    
    /// Returns f8settings or nil
    private static var settings: Dictionary<String, String>? {
        get {
            if _settings == nil {
                _settings = Bundle.main.object(forInfoDictionaryKey: "JLSettings") as? Dictionary<String, String>
            }
            return _settings
        }
    }
    
    private static var _settings: Dictionary<String, String>? = nil
    
    /// Returns the given setting or nil if not found
    public static func getSetting(_ settingName: String) -> String? {
        guard let setting = settings?[settingName] else {
            F8Log.debug("Missing \(settingName) in f8Settings")
            return nil
        }
        return setting
    }
    
    
    // Settings for flash and camera
    private static let userSetting = UserDefaults.standard
    // Key for flash trigger state
    private static let isFlashMarkerEnabledKey = "isFlashMarkerEnabled"
    // Key for camera state
    private static let isCameraActiveKey = "cameraActive"
    
    
    // Flag that flash trigger is turn on/off
    public static var isFlashMarkerEnabled: Bool {
        get{
            return loadSetting(for: isFlashMarkerEnabledKey) ?? false
        }
        set{
            saveSetting(for: isFlashMarkerEnabledKey, with: newValue)
        }
    }
    
    // Flag that camera is turn on/off
    public static var isCameraActive: Bool {
        get {
            return loadSetting(for: isCameraActiveKey) ?? true
        }
        set{
            saveSetting(for: isCameraActiveKey, with: newValue)
        }
    }
    
    
    // Load value from user default with a given key
    public static func loadSetting<T>(for key: String) -> T? {
        if userSetting.object(forKey: key) != nil {
            if let value = userSetting.object(forKey: key) as? T {
                return value
            }
        }
        return nil
    }
    
    
    // Save value to user default with a given key
    public static func saveSetting<T>(for key: String, with value: T) {
        userSetting.set(value, forKey: key)
    }
    
    private static var _loginCredentialKey = "http://data-dev.f8web.net/"
    
    // Key for camera state
    private static let shouldRememberUserKey = "shouldRememberUser"
    
    public static var shouldRememberUser: Bool {
        get{
            return loadSetting(for: shouldRememberUserKey) ?? false
        }
        set{
            saveSetting(for: shouldRememberUserKey, with: newValue)
        }
    }
    
    public static func saveLoginCredential(_ loginCredential: F8LoginCredential) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        var loginCredentialData = Data()
        do {
             loginCredentialData = try encoder.encode(loginCredential)
        } catch {
            F8Log.warn("Failed to encode login credential, error: \(error)")
        }
        A0SimpleKeychain().setData(loginCredentialData, forKey: _loginCredentialKey)
    }
    
    public static func retrieveLoginCrendential(callback: @escaping (Error?, F8LoginCredential?) -> Void) {
        guard let loginCredentialData = A0SimpleKeychain().data(forKey:  _loginCredentialKey) else {
            let error = F8LoginCredentialsError.noLoginCredentials("No login info is found in keychain!")
            callback(error, nil)
            return
        }
        
        let decoder = JSONDecoder()
        
        do {
            let loginCredential = try decoder.decode(F8LoginCredential.self, from: loginCredentialData)
            callback(nil, loginCredential)
        } catch {
            callback(F8LoginCredentialsError.failedDecode(error), nil)
        }
    }
    
    public static func removeLoginCredential() {}
    
}
