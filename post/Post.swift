//
//  Post.swift
//  post
//
//  Created by José María Delgado  on 23/11/16.
//  Copyright © 2016 José María. All rights reserved.
//

import Foundation

class Post {
    
    var postKey: String
    var postDict: Dictionary<String, String>
    
    init(postKey: String, postDict: Dictionary<String, String>) {
        self.postKey = postKey
        self.postDict = postDict
    }
} 
