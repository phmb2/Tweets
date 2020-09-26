//
//  Notification.swift
//  Tweets
//
//  Created by Pedro Barbosa on 21/07/20.
//  Copyright © 2020 Pedro Barbosa. All rights reserved.
//

import Foundation

enum NotificationType: Int {
    case follow
    case like
    case reply
    case retweet
    case mention
}

struct Notification {
    var tweetId: String?
    var timestamp: Date!
    var user: User
    //var tweet: Tweet?
    var type: NotificationType!
    
    init(user: User, dictionary: [String: AnyObject]) {
        self.user = user
        
        if let tweetId = dictionary["tweetId"] as? String {
            self.tweetId = tweetId
        }
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        
        if let type = dictionary["type"] as? Int {
            self.type = NotificationType(rawValue: type)
        }
    }
}
