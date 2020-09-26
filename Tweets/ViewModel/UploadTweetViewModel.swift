//
//  UploadTweetViewModel.swift
//  Tweets
//
//  Created by Pedro Barbosa on 27/06/20.
//  Copyright © 2020 Pedro Barbosa. All rights reserved.
//

import UIKit

enum UploadTweetConfiguration {
    case tweet
    case reply(Tweet)
}

struct UploadTweetViewModel {
    
    let actionButtonTitle: String
    let placeholderText: String
    var showReplyLabel: Bool
    var replyText: String?
    
    init(config: UploadTweetConfiguration) {
        switch config {
        case .tweet:
            actionButtonTitle = "Tweet"
            placeholderText = "What's happening"
            showReplyLabel = false
        case .reply(let tweet):
            actionButtonTitle = "Reply"
            placeholderText = "Tweet your reply"
            showReplyLabel = true
            replyText = "Replying to @\(tweet.user.username)"
            
        }
    }
}
