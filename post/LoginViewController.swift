//
//  ViewController.swift
//  post
//
//  Created by José María Delgado  on 22/11/16.
//  Copyright © 2016 José María. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class LoginViewController: UIViewController {
    
    var registeredUsersNumberLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 40, weight: UIFontWeightThin)
        label.textColor = UIColor.black
        
        return label
    }()
    
    var registeredUsersTitleLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.black
        label.text = "Registered Users"
        
        return label
    }()
    
    let databaseRef = FIRDatabase.database().reference()
    let storage = FIRStorage.storage()
    var storageRef = FIRStorageReference()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storageRef = self.storage.reference(forURL: "gs://post-aa56c.appspot.com")
        self.view.backgroundColor = UIColor(red: 240, green: 238, blue: 246)
        
        self.getAppStats()
        
        self.setupConstraints()
    }
    
    func getAppStats() {
        self.databaseRef.child("app-stats").observe(.value, with: { snapshot in
            print("chema", snapshot)
            let value = snapshot.value as? NSDictionary
            let registeredUsers = value?["registered-users"] as! Int
            var installations = value?["installations"] as! Int
            self.registeredUsersNumberLabel.text = String(registeredUsers)
            if self.defaults.bool(forKey: "notFirstOpening") == false {
                installations += 1
                self.databaseRef.child("app-stats").setValue(["installations": installations, "registered-users": registeredUsers])
                self.defaults.set(true, forKey: "notFirstOpening")
            }
        })
    }
    
    func setupConstraints() {
        view.addSubview(registeredUsersNumberLabel)
        view.addSubview(registeredUsersTitleLabel)
        
        registeredUsersNumberLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        registeredUsersNumberLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registeredUsersNumberLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        
        registeredUsersTitleLabel.topAnchor.constraint(equalTo: registeredUsersNumberLabel.bottomAnchor, constant: 0).isActive = true
        registeredUsersTitleLabel.leftAnchor.constraint(equalTo: registeredUsersNumberLabel.leftAnchor).isActive = true
        registeredUsersTitleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

