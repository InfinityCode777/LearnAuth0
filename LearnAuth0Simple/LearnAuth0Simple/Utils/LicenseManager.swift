////
////  LicenseManager.swift
////  F8SDK
////
////  Created by YICHUN ZHANG on 3/2/18.
////
//
//import UIKit
//
//class LicenseManager: NSObject {
//    
//    // TODO: Can possible move this key into web service
//    private static let encriptKey = "F6EA4DB50370"
//    
//    /// Should be moved out of here.  Should take string such as bundle ID.
//    public static func generateKey(data:String) -> String
//    {
//        let licenseStr = data.aes256Encrypt(withKey: encriptKey)
//        
//        return licenseStr!
//    }
//    
//    public static func verifyKey(licenseStr:String) ->Bool
//    {
//        
//        
//        //        let testID = "com.figur8me.f8sportsapp.dev"
//        //  let generateKey = LicenseManager.generateKey(data: testID)
//        
//        let bundleID = (licenseStr as NSString).aes256Decrypt(withKey: encriptKey)
//        
//        return bundleID == Bundle.main.bundleIdentifier
//        
//    }
//    public static func registerSDK(key:String)->Bool
//    {
//        let ret = LicenseManager.verifyKey(licenseStr: key)
//        return ret
//    }
//    public static func isRegistered()->Bool
//    {
//        return true;
//    }
//}


import UIKit

public class LicenseManager {
    
    public static func isRegistered() -> Bool {
      return true
    }
    
}
