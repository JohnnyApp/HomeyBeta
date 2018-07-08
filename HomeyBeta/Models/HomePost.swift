//
//  HomePost.swift
//  HomeyBeta
//
//  Created by jonathan laroco on 7/1/18.
//  Copyright © 2018 Johnny Laroco. All rights reserved.
//

import Foundation

class HomePost {
    var id:String
    var author:UserProfile
    var house:String
    var text:String
    var timestamp: Double
    
    init(id:String, author:UserProfile, house:String, text:String, timestamp: Double) {
        self.id = id
        self.author = author
        self.house = house
        self.text = text
        self.timestamp = timestamp
    }
}
