//
//  UserProfile.swift
//  HomeyBeta
//
//  Created by jonathan laroco on 7/1/18.
//  Copyright © 2018 Johnny Laroco. All rights reserved.
//

import Foundation

class UserProfile {
    var uid:String
    var username:String
    var photoURL:URL
    
    init(uid:String, username:String,photoURL:URL) {
        self.uid = uid
        self.username = username
        self.photoURL = photoURL
    }
}
