//
//  User.swift
//  Tweets
//
//  Created by Pedro Barbosa on 30/05/20.
//  Copyright © 2020 Pedro Barbosa. All rights reserved.
//

import Foundation
import Firebase

struct User {
    let uid: String
    let email: String
    var fullname: String
    var username: String
    var profileImageUrl: URL?
    var isFollowed = false
    var stats: UserStats?
    var bio: String?
    
    var isCurrentUser: Bool {
        return Auth.auth().currentUser?.uid == uid
    }
    
    init(uid: String, dictionary: [String: AnyObject]) {
        self.uid = uid
        
        self.email = dictionary["email"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        
        if let bio = dictionary["bio"] as? String {
            self.bio = bio
        }
        
        if let profileImageUrlString = dictionary["profileImageUrl"] as? String {
            guard let url = URL(string: profileImageUrlString) else { return }
            self.profileImageUrl = url
        }
    }
}

struct UserStats {
    var following: Int
    var followers: Int
}
