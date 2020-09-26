//
//  NotificationService.swift
//  Tweets
//
//  Created by Pedro Barbosa on 21/07/20.
//  Copyright © 2020 Pedro Barbosa. All rights reserved.
//

import Firebase

struct NotificationService {
    static let shared = NotificationService()
    
//    func uploadNotification(type: NotificationType, tweet: Tweet? = nil, user: User? = nil) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//
//        var values: [String: Any] = ["uid": uid, "timestamp": Int(NSDate().timeIntervalSince1970), "type": type.rawValue]
//
//        if let tweet = tweet {
//            values["tweetId"] = tweet.tweetId
//            REF_NOTIFICATIONS.child(tweet.user.uid).childByAutoId().updateChildValues(values)
//        } else if let user = user {
//            REF_NOTIFICATIONS.child(user.uid).childByAutoId().updateChildValues(values)
//        }
//    }
    
    func uploadNotification(toUser user: User, type: NotificationType, tweetId: String? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var values: [String: Any] = ["uid": uid, "timestamp": Int(NSDate().timeIntervalSince1970), "type": type.rawValue]
        
        if let tweetId = tweetId {
            values["tweetId"] = tweetId
        }
        
        REF_NOTIFICATIONS.child(user.uid).childByAutoId().updateChildValues(values)
    }
    
    fileprivate func getNotifications(uid: String, completion: @escaping([Notification]) -> Void) {
        var notifications = [Notification]()
        
        REF_NOTIFICATIONS.child(uid).observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            UserService.shared.fetchUser(uid: uid) { user in
                let notification = Notification(user: user, dictionary: dictionary)
                notifications.append(notification)
                completion(notifications)
            }
        }
    }
    
    func fetchNotifications(completion: @escaping([Notification]) -> Void) {
        let notifications = [Notification]()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Make sure notification exist for user
        REF_NOTIFICATIONS.child(uid).observeSingleEvent(of: .value) { snapshot in
            if !snapshot.exists() {
                // This means user has no notifications
                completion(notifications)
            } else {
                self.getNotifications(uid: uid, completion: completion)
            }
        }
    }
}
