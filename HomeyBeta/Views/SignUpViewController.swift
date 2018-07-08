//
//  SignUpViewController.swift
//  HomeyBeta
//
//  Created by jonathan laroco on 6/21/18.
//  Copyright © 2018 Johnny Laroco. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    var window: UIWindow?
    
    @IBOutlet weak var UsernameTxt: UITextField!
    @IBOutlet weak var EmailTxt: UITextField!
    @IBOutlet weak var FirstNameTxt: UITextField!
    @IBOutlet weak var LastNameTxt: UITextField!
    @IBOutlet weak var DateOfBirthTxt: UITextField!
    @IBOutlet weak var PasswordTxt: UITextField!
    @IBOutlet weak var RetypePasswordTxt: UITextField!
    @IBOutlet weak var ProfileImage: UIImageView!
    @IBOutlet weak var TapToChangeBtn: UIButton!
    
    var continueButton:RoundedWhiteButton!
    var activityView:UIActivityIndicatorView!
    var imagePicker:UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadViewData()
    }
    
    @objc func openImagePicker(_ sender:Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        EmailTxt.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillAppear), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        EmailTxt.resignFirstResponder()
        FirstNameTxt.resignFirstResponder()
        LastNameTxt.resignFirstResponder()
        DateOfBirthTxt.resignFirstResponder()
        UsernameTxt.resignFirstResponder()
        PasswordTxt.resignFirstResponder()
        RetypePasswordTxt.resignFirstResponder()
        
        
        NotificationCenter.default.removeObserver(self)
    }
    @IBAction func backToMenu(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
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
        let firstname = FirstNameTxt.text
        let lastname = LastNameTxt.text
        let DOB = DateOfBirthTxt.text
        let password = PasswordTxt.text
        let retypepassword = RetypePasswordTxt.text
        let formFilled = email != nil && email != "" && password != nil && password != "" && firstname != nil && firstname != "" && lastname != nil && lastname != "" && DOB != nil && DOB != "" && retypepassword != nil && retypepassword != ""
        setContinueButton(enabled: formFilled)
    }
    
    @objc func SignUp() {
        //LAST STOP HERE...
        guard let email = EmailTxt.text else {return}
        guard let firstname = FirstNameTxt.text else {return}
        guard let lastname = LastNameTxt.text else {return}
        guard let DOB = DateOfBirthTxt.text else {return}
        guard let username = UsernameTxt.text else {return}
        guard let password = PasswordTxt.text else {return}
        guard let retypepassword = RetypePasswordTxt.text else {return}
        guard let image = ProfileImage.image else { return }
        
        setContinueButton(enabled: false)
        continueButton.setTitle("", for: .normal)
        activityView.startAnimating()
        
        if isValidDate(dateString: DOB) == false {
            DateOfBirthTxt.text = ""
            self.PresentErrorAlert(ErrorTitle: "Incorrect date format", ErrorMesage: "Please enter a correct date using the following format (MM/DD/YYYY)")
            self.activityView.stopAnimating()
            self.loadViewData()
            return
        }
        
        if password != retypepassword {
            self.PresentErrorAlert(ErrorTitle: "Passwords are incorrect", ErrorMesage: "Please re-enter matching password")
            PasswordTxt.text = ""
            RetypePasswordTxt.text = ""
            self.activityView.stopAnimating()
            self.loadViewData()
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if error == nil && user != nil {
                //Upload Image
                self.uploadProfileImage(image) { url in
                    if url != nil {
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequest?.displayName = username
                        changeRequest?.commitChanges { error in
                            if error == nil {
                                Auth.auth().currentUser?.sendEmailVerification { (error) in
                                    if error == nil {
                                        self.saveProfile(username: username, firstname: firstname, lastname: lastname, DOB: DOB, profileImageURL: url!) { success in
                                            if success {
                                                self.PresentErrorAlert(ErrorTitle: "Welcome!", ErrorMesage: "An email verification was sent. Please verify your email to join or create a new home.")
                                            }
                                        }
                                    } else {
                                        self.PresentErrorAlert(ErrorTitle: "Error with Email Verification", ErrorMesage: error!.localizedDescription)
                                        self.resetTextFields()
                                        self.activityView.stopAnimating()
                                        self.loadViewData()
                                        print("Error Creating User: \(error!.localizedDescription)")
                                    }
                                }
                            } else {
                                self.PresentErrorAlert(ErrorTitle: "Error with Sign up", ErrorMesage: error!.localizedDescription)
                                self.resetTextFields()
                                self.activityView.stopAnimating()
                                self.loadViewData()
                                print("Error Creating User: \(error!.localizedDescription)")
                            }
                        }
                    }
                }
            } else {
                //Error or User is null
                self.PresentErrorAlert(ErrorTitle: "Error with Sign up", ErrorMesage: error!.localizedDescription)
                self.resetTextFields()
                self.activityView.stopAnimating()
                self.loadViewData()
                print("Error Creating User: \(error!.localizedDescription)")
            }
            
        }
        
    }
    
    func uploadProfileImage(_ image:UIImage, completion: @escaping ((_ url:URL?)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("user/\(uid)")
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.75) else { return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {
                if let url = metaData?.downloadURL() {
                    completion(url)
                } else {
                    completion(nil)
                }
                // success!
            } else {
                // failed
                completion(nil)
            }
        }
    }
    
    func saveProfile(username:String, firstname:String, lastname:String, DOB:String, profileImageURL:URL, completion: @escaping ((_ success:Bool)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print("AFTER getting user ID")
        let databaseRef = Database.database().reference().child("users/profile/\(uid)")
        
        var usrname:String
        if (username == "") {
            usrname = firstname + " " + lastname
        } else {
            usrname = username
        }
        
        let userObject = [
            "Username": usrname,
            "FirstName": firstname,
            "LastName": lastname,
            "DateOfBirth": DOB,
            "type": "tenant",
            "PhotoURL": profileImageURL.absoluteString
            ] as [String:Any]
        
        databaseRef.setValue(userObject) { error, ref in
            completion(error == nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Resigns the target textField and assigns the next textField in the form.
        
        switch textField {
        case EmailTxt:
            EmailTxt.resignFirstResponder()
            FirstNameTxt.becomeFirstResponder()
            break
        case FirstNameTxt:
            FirstNameTxt.resignFirstResponder()
            LastNameTxt.becomeFirstResponder()
            break
        case LastNameTxt:
            LastNameTxt.resignFirstResponder()
            DateOfBirthTxt.becomeFirstResponder()
            break
        case DateOfBirthTxt:
            DateOfBirthTxt.resignFirstResponder()
            UsernameTxt.becomeFirstResponder()
            break
        case UsernameTxt:
            UsernameTxt.resignFirstResponder()
            PasswordTxt.becomeFirstResponder()
            break
        case PasswordTxt:
            PasswordTxt.resignFirstResponder()
            RetypePasswordTxt.becomeFirstResponder()
            break
        case RetypePasswordTxt:
            SignUp()
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
    
    func loadViewData() {
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        
        continueButton = RoundedWhiteButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        continueButton.setTitleColor(secondaryColor, for: .normal)
        continueButton.setTitle("Continue", for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.bold)
        continueButton.center = CGPoint(x: view.center.x, y: view.frame.height - continueButton.frame.height - 24)
        continueButton.highlightedColor = UIColor(white: 1.0, alpha: 1.0)
        continueButton.defaultColor = UIColor.white
        continueButton.addTarget(self, action: #selector(SignUp), for: .touchUpInside)
        
        view.addSubview(continueButton)
        setContinueButton(enabled: false)
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.color = secondaryColor
        activityView.frame = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
        activityView.center = continueButton.center
        
        view.addSubview(activityView)
        
        EmailTxt.delegate = self
        FirstNameTxt.delegate = self
        LastNameTxt.delegate = self
        DateOfBirthTxt.delegate = self
        UsernameTxt.delegate = self
        PasswordTxt.delegate = self
        RetypePasswordTxt.delegate = self
        
        EmailTxt.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        FirstNameTxt.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        LastNameTxt.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        DateOfBirthTxt.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        UsernameTxt.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        PasswordTxt.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        RetypePasswordTxt.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        ProfileImage.isUserInteractionEnabled = true
        ProfileImage.addGestureRecognizer(imageTap)
        ProfileImage.layer.cornerRadius = ProfileImage.bounds.height / 2
        ProfileImage.clipsToBounds = true
        TapToChangeBtn.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
    }
    func PresentErrorAlert(ErrorTitle: String,ErrorMesage: String) {
        let alert = UIAlertController(title: ErrorTitle, message: ErrorMesage, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    func resetTextFields() {
        EmailTxt.text = ""
        FirstNameTxt.text = ""
        LastNameTxt.text = ""
        DateOfBirthTxt.text = ""
        UsernameTxt.text = ""
        PasswordTxt.text = ""
        RetypePasswordTxt.text = ""
    }
    
    func isValidDate(dateString: String) -> Bool {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MM/dd/yyyy"
        if let _ = dateFormatterGet.date(from: dateString) {
            //date parsing succeeded, if you need to do additional logic, replace _ with some variable name i.e date
            return true
        } else {
            // Invalid date
            return false
        }
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.ProfileImage.image = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
