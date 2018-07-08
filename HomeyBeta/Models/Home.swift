//
//  Home.swift
//  HomeyBeta
//
//  Created by jonathan laroco on 7/2/18.
//  Copyright © 2018 Johnny Laroco. All rights reserved.
//

import Foundation

class Home {
    var id:String
    var housename:String
    var address1:String
    var address2:String
    var city:String
    var state:String
    var zipcode:String
    
    init(id:String, housename:String, address1:String, address2:String, city:String, state:String, zipcode:String) {
        self.id = id
        self.housename = housename
        self.address1 = address1
        self.address2 = address2
        self.city = city
        self.state = state
        self.zipcode = zipcode
    }
}
