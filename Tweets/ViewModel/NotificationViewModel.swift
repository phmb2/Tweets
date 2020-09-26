//
//  NotificationViewModel.swift
//  Tweets
//
//  Created by Pedro Barbosa on 23/07/20.
//  Copyright © 2020 Pedro Barbosa. All rights reserved.
//

import UIKit

struct NotificationViewModel {
    
    private let notification: Notification
    private let type: NotificationType
    private let user: User
    
    var timestamp: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        
        return formatter.string(from: notification.timestamp, to: now) ?? ""
    }
    
    var notificationMessage: String {
        switch type {
            case .follow: return " started following you"
            case .like: return " liked your tweet"
            case .reply: return " replied your tweet"
            case .retweet: return " retweeted your tweet"
            case .mention: return " mentioned you in a tweet"
        }
    }
    
    var notificationText: NSAttributedString? {
        
        guard let timestamp = timestamp else { return nil }
        
        let attributedText = NSMutableAttributedString(string: user.username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: notificationMessage, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        attributedText.append(NSAttributedString(string: " \(timestamp)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        
        return attributedText
    }
    
    var profileImageUrl: URL? {
        return user.profileImageUrl
    }
    
    var followButtonText: String {
        return user.isFollowed ? "Following" : "Follow"
    }
    
    var hideFollowButton: Bool {
        return type != .follow
    }
    
    init(notification: Notification) {
        self.notification = notification
        self.type = notification.type
        self.user = notification.user
    }
}
