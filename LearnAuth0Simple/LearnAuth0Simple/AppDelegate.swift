//
//  AppDelegate.swift
//  LearnAuth0Simple
//
//  Created by Jing Wang on 5/21/18.
//  Copyright © 2018 figur8 Inc. All rights reserved.
//

import UIKit
import Auth0

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let authManager = F8Auth0Manager.sharedInstance()!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Try to use cloud upload
        if let (clientID, domain, apiBaseURL, APIIdentifier) = getF8UploadParams(){
            
            /// Set up the authentication manager
            authManager.registerAuth0(clientID: clientID, domain: domain, session: URLSession.shared, apiIdentifier: APIIdentifier)
            
//            /// Register the API base URL with the data manager
//            dataManager.setAPI(baseURL: apiBaseURL)
            
            
        } else {
            F8Log.warn("Could not get info to proceed to login, add key/value pairs for keys: 'clientID', 'domain' and 'apiBaseURL'")
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return Auth0.resumeAuth(url, options: options)
    }
    
    /// Get credentials for cloud upload from plist
    /// Returns (uploadUrl, uploadToken) or nil if error
    public func getF8UploadParams() -> (String, String, String, String)? {
        guard let apiBaseURL = F8AppUtils.getSetting("apiBaseURL") else { return nil }
        guard let clientID = F8AppUtils.getSetting("ClientID") else { return nil }
        guard let domain = F8AppUtils.getSetting("Domain") else { return nil }
        guard let APIIdentifier = F8AppUtils.getSetting("APIIdentifier") else { return nil }
        return (clientID, domain, apiBaseURL, APIIdentifier)
    }
}

