//
//  AddHouseViewController.swift
//  HomeyBeta
//
//  Created by jonathan laroco on 7/2/18.
//  Copyright © 2018 Johnny Laroco. All rights reserved.
//

import UIKit
import Firebase

class AddHouseViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var homeProfileImage: UIImageView!
    @IBOutlet weak var tapToChangeBtn: UIButton!
    @IBOutlet weak var houseNameTxt: UITextField!
    @IBOutlet weak var houseAddress1Txt: UITextField!
    @IBOutlet weak var houseAddress2Txt: UITextField!
    @IBOutlet weak var houseCityTxt: UITextField!
    @IBOutlet weak var houseStateTxt: UITextField!
    @IBOutlet weak var houseZipCodeTxt: UITextField!
    
    var continueButton:RoundedWhiteButton!
    var activityView:UIActivityIndicatorView!
    var imagePicker:UIImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadViewData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    @IBAction func HandleCancel(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func CreateHouse() {
        guard let userProfile = UserService.currentUserProfile else { return }
        guard let houseName = houseNameTxt.text else {return}
        guard let houseAdd1 = houseAddress1Txt.text else {return}
        guard let houseAdd2 = houseAddress2Txt.text else {return}       //Potential Issue???
        guard let houseCity = houseCityTxt.text else {return}
        guard let houseState = houseStateTxt.text else {return}
        guard let houseZipCode = houseZipCodeTxt.text else {return}
        guard let image = homeProfileImage.image else { return }

        // Firebase code here
        
        let postRef = Database.database().reference().child("houses").childByAutoId()
        
        let postObject = [
            "users": [
                "uid": userProfile.uid,
                "username": userProfile.username,
                "photoURL": userProfile.photoURL.absoluteString
            ],
            "houseName": houseName,
            "houseAddress1": houseAdd1,
            "houseAddress2": houseAdd2,
            "houseCity": houseCity,
            "houseState": houseState,
            "houseZipCode": houseZipCode
            ] as [String:Any]
        
        self.uploadHouseProfileImage(image) { url in
            if url != nil {
                postRef.setValue(postObject, withCompletionBlock: { error, ref in
                    if error == nil {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        let alert = UIAlertController(title: "Error", message: "There was an error creating the house", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
    }

    @objc func openImagePicker(_ sender:Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func textFieldChanged(_ target:UITextField) {
        let housename = houseNameTxt.text
        let houseadd1 = houseAddress1Txt.text
        //let houseadd2 = houseAddress2Txt.text
        let housecity = houseCityTxt.text
        let housestate = houseStateTxt.text
        let housezipcode = houseZipCodeTxt.text
        
        let formFilled = housename != nil && housename != "" && houseadd1 != nil && houseadd1 != "" && housecity != nil && housecity != "" && housestate != nil && housestate != "" && housezipcode != nil && housezipcode != ""
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
    
    func uploadHouseProfileImage(_ image:UIImage, completion: @escaping ((_ url:URL?)->())) {
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
    
    func loadViewData() {
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        
        continueButton = RoundedWhiteButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        continueButton.setTitleColor(secondaryColor, for: .normal)
        continueButton.setTitle("Continue", for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.bold)
        continueButton.center = CGPoint(x: view.center.x, y: view.frame.height - continueButton.frame.height - 24)
        continueButton.highlightedColor = UIColor(white: 1.0, alpha: 1.0)
        continueButton.defaultColor = UIColor.white
        continueButton.addTarget(self, action: #selector(CreateHouse), for: .touchUpInside)
        
        view.addSubview(continueButton)
        setContinueButton(enabled: false)
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.color = secondaryColor
        activityView.frame = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
        activityView.center = continueButton.center
        
        view.addSubview(activityView)
        
        houseNameTxt.delegate = self
        houseAddress1Txt.delegate = self
        houseAddress2Txt.delegate = self
        houseCityTxt.delegate = self
        houseStateTxt.delegate = self
        houseZipCodeTxt.delegate = self
        
        houseNameTxt.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        houseAddress1Txt.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        houseAddress2Txt.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        houseCityTxt.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        houseStateTxt.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        houseZipCodeTxt.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        homeProfileImage.isUserInteractionEnabled = true
        homeProfileImage.addGestureRecognizer(imageTap)
        homeProfileImage.layer.cornerRadius = homeProfileImage.bounds.height / 2
        homeProfileImage.clipsToBounds = true
        tapToChangeBtn.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
    }
}

extension AddHouseViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.homeProfileImage.image = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
