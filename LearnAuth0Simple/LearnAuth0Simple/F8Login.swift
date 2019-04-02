//
//  F8Login.swift
//  LearnAuth0Simple
//
//  Created by Jing Wang on 5/21/18.
//  Copyright © 2018 figur8 Inc. All rights reserved.
//

import UIKit
import Auth0
import SimpleKeychain


class F8Login: UIViewController {
    
     var timerToShow = Timer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let uuid = UUID().uuidString
        print(uuid)
        
        timerToShow = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(testAPI01), userInfo: nil, repeats: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @objc func testAPI01() {
        #if DEBUG
        print("Enter testAPI01")
        #endif
        Auth0
            .webAuth()
            .audience("https://infinity-coding7.auth0.com/userinfo")
            .start {result in
                switch result {
                case .success(let credentials):
                    print("Obtained credentials: \(credentials)")
                case .failure(let error):
                    print("Failed with \(error)")
                }
                
        }
    }
    
}

