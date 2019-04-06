//
//  F8Auth0Manager.swift
//  F8SDK
//
//  Created by Jing Wang on 11/29/18.
//

import Foundation
import SimpleKeychain
import Auth0

public protocol F8Auth0ManagerProtocol {
    
    /// Returns true/false to indicate whether auth0 parameters are properly set
    var isRegistered: Bool { get }
    
    static func sharedInstance() -> F8Auth0ManagerProtocol?
    
    func registerAuth0(clientID: String, domain: String, session: URLSession, apiIdentifier: String)
    func showLogin(_ callback: @escaping (Result<Credentials>) -> ())
    
    /// Access token for the currently logged in user
    var accessToken: String? { get }
    
    /// Info about the currently logged in user
    var profile: UserInfo? { get }
    
    var credentials: Credentials? { get }
    
    /// Function to remove all credential and profile info from memory
    func logout()
    
    /// Sign with email/username and password
    func performLoginWith(usernameOrEmail: String, password: String, _ completion: @escaping (Result<Credentials>) -> ())
}
