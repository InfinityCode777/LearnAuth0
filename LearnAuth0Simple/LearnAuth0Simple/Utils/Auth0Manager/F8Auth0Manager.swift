import Foundation
import SimpleKeychain
import Auth0

public class F8Auth0Manager: F8Auth0ManagerProtocol {
    
    
    
    /// Shared auth0 manager
    public static func sharedInstance() -> F8Auth0ManagerProtocol?
    {
        if(LicenseManager.isRegistered())
        {
            return instance
        }
        else
        {
            F8Log.warn("F8SDK not implemented")
            return nil
        }
    }
    
    /// Singleton
    private static let instance = F8Auth0Manager()
    
    private let utils = Utils.sharedInstance
    
    /// Default constructor.  Singleton pattern.
    private init () {}
    
    private var clientId: String? = nil
    private var domain: String? = nil
    private var session = URLSession.shared
    private var apiIdentifier: String? = nil
    
    /// User profile & credentials pooled via auth0
    public var profile: UserInfo?
    public var credentials: Credentials?
    
    /// Session Token (can use credentialsManager later:  https://auth0.com/docs/quickstart/native/ios-swift/03-user-sessions)
    public var accessToken: String? = nil
    public var idToken: String? = nil //DEBUG
    
    /// Sets auth0 credentials
    public func registerAuth0(clientID: String, domain: String, session: URLSession, apiIdentifier: String) {
        self.clientId = clientID
        self.domain = domain
        self.session = session
        self.apiIdentifier = apiIdentifier
    }
    
    /// Flag indicating whether all auth0 params are properly set
    public var isRegistered: Bool {
        get {
            return clientId != nil && domain != nil && apiIdentifier != nil
        }
    }
    
    /// Shows a login.  Returns success with credentials, or error with error
    public func showLogin(_ callback: @escaping (Result<Credentials>) -> ()) {
        guard let clientId = clientId, let domain = domain, let apiIdentifier = apiIdentifier else {
            F8Log.error("ClientID, domain or apiIdentifier not properly supplied!")
            return
        }
        
        // Reset user access token and profile so that we can refresh them
        self.accessToken = nil
        self.profile = nil
        
        Auth0
            .webAuth(clientId: clientId, domain: domain)
            .audience(apiIdentifier)
            .scope("openid profile read:datasets")
            .start { [weak self] in
                switch $0 {
                case .failure(let error):
                    DispatchQueue.main.async {
                        return callback(Result.failure(error: error))
                    }
                case .success(let credentials):
                    
                    self?.credentials = credentials
                    
                    // Get the user's profile
                    if let accessToken = credentials.accessToken {
                        
                        // Store access token
                        self?.accessToken = accessToken
                        
                        // Get profile
                        self?.retrieveProfile(accessToken: accessToken, { error in
                            
                            // Upon error, log an error retrieving the profile...
                            if let error = error {
                                F8Log.error("Error retrieving profile: \(error)")
                            }
                            
                            // ...but either way, just flag success for now
                            DispatchQueue.main.async {
                                return callback(Result.success(result: credentials))
                            }
                        })
                    }
                    else {
                        // Couldn't get userID, same as failed login
                        DispatchQueue.main.async {
                            return callback(Result.failure(error: AuthenticationError(string: "No access token found!", statusCode: -1)))
                        }
                    }
                }
        }
    }
    
    /// Gets the users profile.  Calls callback with nil upon success, or error
    internal func retrieveProfile(accessToken: String, _ callback: @escaping (Error?) -> ()) {
        guard let clientId = clientId, let domain = domain else {
            F8Log.error("ClientID, domain or apiIdentifier not properly supplied!")
            return
        }
        
        Auth0
            .authentication(clientId: clientId, domain: domain, session: self.session)
            .userInfo(withAccessToken: accessToken)
            .start {[weak self] result in
                switch(result) {
                case .success(let profile):
                    self?.profile = profile
                    callback(nil)
                case .failure(let error):
                    callback(error)
                }
        }
    }
    
    /// Reset user access token and profile so that we can refresh them
    public func logout() {
        self.accessToken = nil
        self.profile = nil
    }
    
    /// Native login with username/email and password
    public func performLoginWith(usernameOrEmail: String, password: String, _ completion: @escaping (Result<Credentials>) -> ()) {
        
        guard let clientId = clientId, let domain = domain else {
            F8Log.error("ClientID, domain or apiIdentifier not properly supplied!")
            return
        }
        
        Auth0
            .authentication(clientId: clientId, domain: domain, session: self.session)
            .login(
                usernameOrEmail: usernameOrEmail,
                password: password,
                realm: "Username-Password-Authentication",
//                audience: apiIdentifier,
                scope: "openid profile")
            .start {[weak self] result in
                
                switch result {
                case .success(let credentials):
                    // Get the user's profile
                    if let accessToken = credentials.accessToken {
                        
                        // Store access token
                        self?.accessToken = accessToken
                        
                        // Get profile
                        self?.retrieveProfile(accessToken: accessToken, { error in
                            
                            print("accessToken = \(accessToken)")
                            // Upon error, log an error retrieving the profile...
                            if let error = error {
                                F8Log.error("Error retrieving profile: \(error)")
                            }
                            
                            // ...but either way, just flag success for now
                            DispatchQueue.main.async {
                                return completion(Result.success(result: credentials))
                            }
                        })
                    }
                    else {
                        // Couldn't get userID, same as failed login
                        DispatchQueue.main.async {
                            return completion(Result.failure(error: AuthenticationError(string: "No access token found!", statusCode: -1)))
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        return completion(Result.failure(error: error))
                    }
                }
        }
    }
    
    public func performSignUp(_ signUPCredential: F8SignUpCredential, _ completion: @escaping (DatabaseUser?, Error?) -> ()) {
//        self.view.endEditing(true)
//        self.loading = true
       let emailOrUsernameString = signUPCredential.emailOrUsername.lowercased().trimmingCharacters(in: .whitespaces)
       let passwordString = signUPCredential.passowrd.trimmingCharacters(in: .whitespaces)
        
        Auth0
            .authentication()
            .createUser(
                email: emailOrUsernameString,
                password: passwordString,
                connection: "Username-Password-Authentication",
                userMetadata: ["first_name": signUPCredential.firstName,
                               "last_name": signUPCredential.lastName]
            )
            .start { result in
                DispatchQueue.main.async {
//                    self.loading = false
                    switch result {
                    case .success(let user):
//                        self.showAlertForSuccess("User Sign up: \(user.email)")
//                        self.performSegue(withIdentifier: "DismissSignUp", sender: nil)
                        completion(user, nil)
                        break
                    case .failure(let error):
//                        self.showAlertForError(error)
                        completion(nil, error)
                        break
                    }
                }
        }
    }
    
    
//    func resetPassword(email: String, connection: String) -> Request<Void, AuthenticationError> {
//        let payload = [
//            "email": email,
//            "connection": connection,
//            "client_id": self.clientId
//        ]
//        let resetPassword = URL(string: "/dbconnections/change_password", relativeTo: self.url)!
//        return Request(session: session, url: resetPassword, method: "POST", handle: noBody, payload: payload, logger: self.logger, telemetry: self.telemetry)
//    }
    
    
    public func resetPassword(email: String, _ completion: @escaping (Request<Void, AuthenticationError>) -> () ) {
        
        guard let clientId = clientId, let domain = domain else {
            F8Log.error("ClientID, domain or apiIdentifier not properly supplied!")
            return
        }
        
        let emailString = email.lowercased().trimmingCharacters(in: .whitespaces)
        let request = Auth0.authentication().resetPassword(email: emailString, connection: "Username-Password-Authentication")
        completion(request)
    }
    
//    func resetPassword(email: String, connection: String, clientID: String, domain: String) -> Request<Void, AuthenticationError> {
//            let payload = [
//                "email": email,
//                "connection": connection,
//                "client_id": sclientID
//            ]
//            let resetPassword = URL(string: "/dbconnections/change_password", relativeTo: domain)!
//            return Request(session: session, url: resetPassword, method: "POST", handle: noBody, payload: payload, logger: self.logger, telemetry: self.telemetry)
//        }
    
}
