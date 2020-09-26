//
//  Tweet.swift
//  Tweets
//
//  Created by Pedro Barbosa on 31/05/20.
//  Copyright © 2020 Pedro Barbosa. All rights reserved.
//

import Foundation

struct Tweet {
    let tweetId: String
    let caption: String
//    let uid: String
    var likes: Int
    let retweetsCount: Int
    var timestamp: Date!
    var user: User
    var didLike = false
    var replyingTo: String?
    
    var isReply: Bool { return replyingTo != nil }
    
    init(user: User, tweetId: String, dictionary: [String: Any]) {
        self.tweetId = tweetId
        self.user = user
        
        self.caption = dictionary["caption"] as? String ?? ""
//        self.uid = dictionary["uid"] as? String ?? ""
        self.likes = dictionary["likes"] as? Int ?? 0
        self.retweetsCount = dictionary["retweets"] as? Int ?? 0
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        
        if let replyingTo = dictionary["replyingTo"] as? String {
            self.replyingTo = replyingTo
        }
    }
}
