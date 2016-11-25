//
//  UploadPostViewController.swift
//  post
//
//  Created by José María Delgado  on 22/11/16.
//  Copyright © 2016 José María. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class UploadPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var textView: UITextView = {
        var textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 25, weight: UIFontWeightBold)
        textView.textColor = .white
        textView.layer.cornerRadius = 0
        
        textView.tintColor = .white
        
        return textView
    }()
    
    lazy var profileImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 5
        imageView.backgroundColor = UIColor(red: 20, green: 20, blue: 20)
        imageView.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    lazy var select: UIButton = {
        var button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("select", for: .normal)
        
        
        button.addTarget(self, action: #selector(handleSelectProfileImageView), for: .touchUpInside)
        
        return button
    }()
    
    lazy var sendButton: UIButton = {
        var button = UIButton(type: .system)
        //button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("SEND", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(registerPostIntoDatabaseWithUID), for: .touchUpInside)
        button.backgroundColor = UIColor(red: 70, green: 170, blue: 150)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.addSubview(profileImageView)
       // self.view.addSubview(register)
        //self.view.addSubview(select)
        self.view.addSubview(textView)
        
        //_ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(registerPostIntoDatabaseWithUID), userInfo: nil, repeats: true)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        let sendButtonView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        sendButton.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: sendButtonView.frame.height)
        sendButtonView.addSubview(self.sendButton)
        
        textView.inputAccessoryView = sendButtonView
        
        self.view.backgroundColor = UIColor(red: 100, green: 200, blue: 180)
        self.textView.backgroundColor = view.backgroundColor
        
        textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        textView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        textView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        textView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        /*profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
         profileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
         profileImageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
         profileImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
         
         select.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
         select.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true*/
        
       /* register.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        register.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        register.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        register.heightAnchor.constraint(equalToConstant: 50).isActive = true*/
        
    }
    
    /*func handleRegister() {
     let imageName = NSUUID().uuidString
     let storageRef = FIRStorage.storage().reference().child("post_images").child("\(imageName).png")
     if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!) {
     storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
     if error != nil {
     print(error!)
     return
     }
     if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
     let values = ["description": "blablablablabla", "user": "555", "imageUrl": profileImageUrl]
     //self.registerPostIntoDatabaseWithUID(uid: imageName, values: values as [String : AnyObject])
     }
     })
     }
     }*/
    
    func registerPostIntoDatabaseWithUID() {
        let ref = FIRDatabase.database().reference()
        let usersReference = ref.child("posts").child(NSUUID().uuidString)
        let values: [String: String] = ["text": self.textView.text!, "timestamp": self.getCurrentUTCDate()]
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err!)
                return
            } else {
                self.textView.resignFirstResponder()
                self.sendButton.alpha = 0
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func getCurrentUTCDate() -> String {
        let date = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone!
        let utcTimeZoneStr = formatter.string(from: date as Date)
        return utcTimeZoneStr
    }
    
    func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardSize!, from: view.window)
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.sendButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -(keyboardViewEndFrame.height)).isActive = true
            })
        print(keyboardSize?.height)
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.sendButton.center.y += keyboardSize.height
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.textView.becomeFirstResponder()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
