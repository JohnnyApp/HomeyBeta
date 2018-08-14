//
//  LoginViewController.swift
//  HomeyBeta
//
//  Created by jonathan laroco on 6/21/18.
//  Copyright © 2018 Johnny Laroco. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var EmailText: UITextField!
    @IBOutlet weak var PasswordTxt: UITextField!
    
    var continueButton:RoundedWhiteButton!
    var activityView:UIActivityIndicatorView!
    var messagehandler = messageHandler()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if messagehandler.resetPasswordHandler == true {
            let alert = UIAlertController(title: "Password Reset", message: "An email was sent. Please follow the instructions to reset your password.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        EmailText.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillAppear), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        EmailText.resignFirstResponder()
        PasswordTxt.resignFirstResponder()
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    @IBAction func goBackToMenu(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func keyboardWillAppear(notification: NSNotification){
        
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        continueButton.center = CGPoint(x: view.center.x,
                                        y: view.frame.height - keyboardFrame.height - 16.0 - continueButton.frame.height / 2)
        activityView.center = continueButton.center
    }
    
    @objc func textFieldChanged(_ target:UITextField) {
        let email = EmailText.text
        let password = PasswordTxt.text
        let formFilled = email != nil && email != "" && password != nil && password != ""
        setContinueButton(enabled: formFilled)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case EmailText:
            EmailText.resignFirstResponder()
            PasswordTxt.becomeFirstResponder()
            break
        case PasswordTxt:
            handleSignIn()
            break
        default:
            break
        }
        return true
    }
    
    func setContinueButton(enabled:Bool) {
        if enabled {
            continueButton.alpha = 1.0
            continueButton.isEnabled = true
        } else {
            continueButton.alpha = 0.5
            continueButton.isEnabled = false
        }
    }
    
    @objc func handleSignIn() {
        guard let email = EmailText.text else { return }
        guard let pass = PasswordTxt.text else { return }
        
        setContinueButton(enabled: false)
        continueButton.setTitle("", for: .normal)
        activityView.startAnimating()
        
        Auth.auth().signIn(withEmail: email, password: pass) { user, error in
            if (error == nil) && (user != nil) {
                if user?.isEmailVerified == false {
                    self.resetForm(ErrorMsg: "Please verify your email before continuing")
                } else {
                    print("User ID: " + user!.uid)
                    UserService.observeUserProfile(user!.uid) { userProfile in
                        print("Go into User Service")
                        UserService.currentUserProfile = userProfile
                    }
                    self.goToHomeSelection()
                }
            } else {
                print("Error logging in: \(error!.localizedDescription)")
                self.resetForm(ErrorMsg: error!.localizedDescription)
            }
        }
    }
    
    func resetForm(ErrorMsg: String) {
        let alert = UIAlertController(title: "Error logging in", message: ErrorMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        setContinueButton(enabled: true)
        continueButton.setTitle("Continue", for: .normal)
        activityView.stopAnimating()
        PasswordTxt.text = ""
    }
    
    func goToHomeSelection() {
        let homeSelectViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeSelectionViewController") as! UINavigationController
        self.present(homeSelectViewController, animated: true)
    }
    
    func loadData() {
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        
        continueButton = RoundedWhiteButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        continueButton.setTitleColor(secondaryColor, for: .normal)
        continueButton.setTitle("Continue", for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.bold)
        continueButton.center = CGPoint(x: view.center.x, y: view.frame.height - continueButton.frame.height - 24)
        continueButton.highlightedColor = UIColor(white: 1.0, alpha: 1.0)
        continueButton.defaultColor = UIColor.white
        continueButton.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
        continueButton.alpha = 0.5
        view.addSubview(continueButton)
        setContinueButton(enabled: false)
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.color = secondaryColor
        activityView.frame = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
        activityView.center = continueButton.center
        
        view.addSubview(activityView)
        
        EmailText.delegate = self
        PasswordTxt.delegate = self
        
        EmailText.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        PasswordTxt.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
}
