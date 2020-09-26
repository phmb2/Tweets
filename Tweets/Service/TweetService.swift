//
//  TweetService.swift
//  Tweets
//
//  Created by Pedro Barbosa on 31/05/20.
//  Copyright © 2020 Pedro Barbosa. All rights reserved.
//

import Firebase

struct TweetService {
    static let shared = TweetService()
    
    func uploadTweet(caption: String, type: UploadTweetConfiguration, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var values = ["uid": uid, "caption": caption, "likes": 0, "retweets": 0, "timestamp": Int(NSDate().timeIntervalSince1970)] as [String: Any]
        
        switch type {
            case .tweet:
                REF_TWEETS.childByAutoId().updateChildValues(values) { (error, ref) in
                    guard let tweetId = ref.key else { return }
                    REF_USER_TWEETS.child(uid).updateChildValues([tweetId: 1], withCompletionBlock: completion)
                }
            case .reply(let tweet):
                values["replyingTo"] = tweet.user.username
                
                REF_TWEET_REPLIES.child(tweet.tweetId).childByAutoId().updateChildValues(values) { (error, ref) in
                    guard let replyKey = ref.key else { return }
                    REF_USER_REPLIES.child(uid).updateChildValues([tweet.tweetId: replyKey], withCompletionBlock: completion)
                }
        }
    }
    
    func fetchTweets(completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_FOLLOWING.child(currentUid).observe(.childAdded) { snapshot in
            
            let followingUid = snapshot.key
            
            REF_USER_TWEETS.child(followingUid).observe(.childAdded) { snapshot in
                let tweetId = snapshot.key
                
                self.fetchTweet(withTweetId: tweetId) { tweet in
                    tweets.append(tweet)
                    completion(tweets)
                }
            }
        }
        
        REF_USER_TWEETS.child(currentUid).observe(.childAdded) { snapshot in
            let tweetId = snapshot.key
            
            self.fetchTweet(withTweetId: tweetId) { tweet in
                tweets.append(tweet)
                completion(tweets)
            }
        }
        
//        REF_TWEETS.observe(.childAdded) { snapshot in
//
//            guard let dictionary = snapshot.value as? [String: Any] else { return }
//
//            guard let uid = dictionary["uid"] as? String else { return }
//
//            let tweetId = snapshot.key
//
//            UserService.shared.fetchUser(uid: uid) { user in
//                let tweet = Tweet(user: user, tweetId: tweetId, dictionary: dictionary)
//                tweets.append(tweet)
//                completion(tweets)
//            }
//        }
    }
    
    func fetchTweets(forUser user: User, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        REF_USER_TWEETS.child(user.uid).observe(.childAdded) { snapshot in
            let tweetId = snapshot.key
            
            self.fetchTweet(withTweetId: tweetId) { tweet in
                tweets.append(tweet)
                completion(tweets)
            }
            
//            REF_TWEETS.child(tweetId).observeSingleEvent(of: .value) { snapshot in
//
//                guard let dictionary = snapshot.value as? [String: Any] else { return }
//
//                guard let uid = dictionary["uid"] as? String else { return }
//
//                UserService.shared.fetchUser(uid: uid) { user in
//                    let tweet = Tweet(user: user, tweetId: tweetId, dictionary: dictionary)
//                    tweets.append(tweet)
//                    completion(tweets)
//                }
//            }
        }
    }
    
    func fetchTweet(withTweetId tweetId: String, completion: @escaping(Tweet) -> Void) {
        REF_TWEETS.child(tweetId).observeSingleEvent(of: .value) { snapshot in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            UserService.shared.fetchUser(uid: uid) { user in
                let tweet = Tweet(user: user, tweetId: tweetId, dictionary: dictionary)
                completion(tweet)
            }
        }
    }
    
    func fetchReplies(forUser user: User, completion: @escaping([Tweet]) -> Void) {
        var replies = [Tweet]()
        
        REF_USER_REPLIES.child(user.uid).observe(.childAdded) { snapshot in
            let tweetKey = snapshot.key
            guard let replyKey = snapshot.value as? String else { return }
            
            REF_TWEET_REPLIES.child(tweetKey).child(replyKey).observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                guard let uid = dictionary["uid"] as? String else { return }
                
                let replyId = snapshot.key
                
                UserService.shared.fetchUser(uid: uid) { user in
                    let reply = Tweet(user: user, tweetId: replyId, dictionary: dictionary)
                    replies.append(reply)
                    completion(replies)
                }
            }
        }
    }
    
    func fetchReplies(forTweet tweet: Tweet, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        REF_TWEET_REPLIES.child(tweet.tweetId).observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            
            guard let uid = dictionary["uid"] as? String else { return }
            
            let tweetId = snapshot.key
            
            UserService.shared.fetchUser(uid: uid) { user in
                let tweet = Tweet(user: user, tweetId: tweetId, dictionary: dictionary)
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func fetchLikes(forUser user: User, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        REF_USER_LIKES.child(user.uid).observe(.childAdded) { snapshot in
            let tweetId = snapshot.key
            self.fetchTweet(withTweetId: tweetId) { likedTweet in
                var tweet = likedTweet
                tweet.didLike = true
                
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func likeTweet(tweet: Tweet, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
        REF_TWEETS.child(tweet.tweetId).child("tweets").setValue(likes)
        
        if tweet.didLike {
            //Unlike tweet
            REF_USER_LIKES.child(uid).child(tweet.tweetId).removeValue { (error, ref) in
                REF_TWEET_LIKES.child(tweet.tweetId).removeValue(completionBlock: completion)
            }
        } else {
            //Like tweet
            REF_USER_LIKES.child(uid).updateChildValues([tweet.tweetId: 1]) { (error, ref) in
                REF_TWEET_LIKES.child(tweet.tweetId).updateChildValues([uid: 1], withCompletionBlock: completion)
            }
        }
    }
    
    func checkUserLikedTweet(_ tweet: Tweet, completion: @escaping(Bool) -> Void) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_LIKES.child(currentUid).child(tweet.tweetId).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
}
