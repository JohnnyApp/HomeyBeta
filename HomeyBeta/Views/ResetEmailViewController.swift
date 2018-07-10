//
//  ResetEmailViewController.swift
//  HomeyBeta
//
//  Created by jonathan laroco on 7/4/18.
//  Copyright © 2018 Johnny Laroco. All rights reserved.
//

import UIKit
import Firebase

class ResetEmailViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var EmailTxt: UITextField!
    
    var continueButton:RoundedWhiteButton!
    var activityView:UIActivityIndicatorView!
    var messagehandler = messageHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadViewData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        EmailTxt.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillAppear), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        EmailTxt.resignFirstResponder()
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    @objc func keyboardWillAppear(notification: NSNotification){
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        continueButton.center = CGPoint(x: view.center.x,
                                        y: view.frame.height - keyboardFrame.height - 16.0 - continueButton.frame.height / 2)
        activityView.center = continueButton.center
    }
    
    @objc func textFieldChanged(_ target:UITextField) {
        let email = EmailTxt.text
        let formFilled = email != nil && email != ""
        setContinueButton(enabled: formFilled)
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
    
    @objc func ResetPassword() {
        guard let email = EmailTxt.text else {return}
        
        setContinueButton(enabled: false)
        continueButton.setTitle("", for: .normal)
        activityView.startAnimating()
        
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil {
                self.SuccessfulEmailSending()
            } else {
                self.HandleSendingError(MessageTitle: "Reset Password", MessageDescription: (error?.localizedDescription)!)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case EmailTxt:
            ResetPassword()
            break
        default:
            break
        }
        return true
    }
    
    func loadViewData() {
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        
        continueButton = RoundedWhiteButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        continueButton.setTitleColor(secondaryColor, for: .normal)
        continueButton.setTitle("Continue", for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.bold)
        continueButton.center = CGPoint(x: view.center.x, y: view.frame.height - continueButton.frame.height - 24)
        continueButton.highlightedColor = UIColor(white: 1.0, alpha: 1.0)
        continueButton.defaultColor = UIColor.white
        continueButton.addTarget(self, action: #selector(ResetPassword), for: .touchUpInside)
        
        view.addSubview(continueButton)
        setContinueButton(enabled: false)
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.color = secondaryColor
        activityView.frame = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
        activityView.center = continueButton.center
        
        view.addSubview(activityView)
        
        EmailTxt.delegate = self
        
        EmailTxt.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    
    func HandleSendingError(MessageTitle: String, MessageDescription:String) {
        let alert = UIAlertController(title: MessageTitle, message: MessageDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true)
        resetForm()
    }
    
    func SuccessfulEmailSending() {
        //Put in Alert Message
        messagehandler.resetPasswordHandler = true
        goToLoginScreen()
        //self.dismiss(animated: false, completion: nil)
    }
    
    func resetForm() {
        EmailTxt.text = ""
        activityView.stopAnimating()
        self.setContinueButton(enabled: true)
        continueButton.setTitle("Continue", for: .normal)
    }
    
    func goToLoginScreen() {
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "loginViewController") as! UIViewController
        self.present(loginViewController, animated: true)
    }
    
    @IBAction func backToLogin(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
}
