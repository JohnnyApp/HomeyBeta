//
//  messageHandlers.swift
//  HomeyBeta
//
//  Created by jonathan laroco on 7/9/18.
//  Copyright © 2018 Johnny Laroco. All rights reserved.
//

import Foundation

struct messageHandler {
    var resetPasswordHandler = false
    var signinHandler = false
    
    init () {
        
    }
    
    mutating func setAllFalse() {
        resetPasswordHandler = false
        signinHandler = false
    }
    
    //Setters -
    mutating func setResetPasswordHandler(set: Bool) {
        resetPasswordHandler = set
    }
    mutating func setSigninHandler(set: Bool) {
        signinHandler = set
    }
    //Setters +
    
    //Getters -
    func getResetPasswordHandler() -> Bool {
        return(resetPasswordHandler)
    }
    func getSigninHandler() -> Bool {
        return(signinHandler)
    }
    //Getters +
    
}
