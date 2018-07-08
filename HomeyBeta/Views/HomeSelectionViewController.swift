//
//  HomeSelectionViewController.swift
//  HomeyBeta
//
//  Created by jonathan laroco on 7/2/18.
//  Copyright © 2018 Johnny Laroco. All rights reserved.
//

import UIKit
import Firebase

class HomeSelectionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func handleLogout(_ sender: Any) {
        try! Auth.auth().signOut()
    }
}
