//
//  ProfileController.swift
//  Tweets
//
//  Created by Pedro Barbosa on 03/06/20.
//  Copyright © 2020 Pedro Barbosa. All rights reserved.
//

import UIKit
import Firebase

private let tweetID = "tweetID"
private let profileHeader = "profileHeader"

class ProfileController: UICollectionViewController {
    
    // MARK: Properties
    
    private var user: User
    
    private var selectedFilter: ProfileFilterOptions = .tweets {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var tweets = [Tweet]()
    private var repliesTweets = [Tweet]()
    private var likedTweets = [Tweet]()
    
    private var currentDataSource: [Tweet] {
        switch selectedFilter {
            case .tweets: return tweets
            case .replies: return repliesTweets
            case .likes: return likedTweets
        }
    }
    
    // MARK: Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchTweets()
        fetchReplies()
        fetchLikedTweets()
        checkUserIsFollowed()
        fetchUserStats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: API Service
    
    func fetchTweets() {
        TweetService.shared.fetchTweets(forUser: user) { tweets in
            self.tweets = tweets
            self.collectionView.reloadData()
        }
    }
    
    func fetchReplies() {
        TweetService.shared.fetchReplies(forUser: user) { tweets in
            self.repliesTweets = tweets
        }
    }
    
    func fetchLikedTweets() {
        TweetService.shared.fetchLikes(forUser: user) { tweets in
            self.likedTweets = tweets
        }
    }
    
    func checkUserIsFollowed() {
        UserService.shared.checkUserIsFollowed(uid: user.uid) { isFollowed in
            self.user.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }
    
    func fetchUserStats() {
        UserService.shared.fetchUserStats(uid: user.uid) { stats in
            self.user.stats = stats
            self.collectionView.reloadData()
        }
    }
    
    // MARK: Helpers
    
    func configureCollectionView() {
        
        collectionView.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .never
        
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: profileHeader)
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: tweetID)
        
        guard let tabHeight = tabBarController?.tabBar.frame.height else { return }
        collectionView.contentInset.bottom = tabHeight
    }
}

// MARK: UICollectionViewDataSource

extension ProfileController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentDataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tweetID, for: indexPath) as! TweetCell
        cell.tweet = currentDataSource[indexPath.row]
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension ProfileController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        var height: CGFloat = 320
        
        if user.bio != nil {
            height += 30
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = TweetViewModel(tweet: currentDataSource[indexPath.row])
        var captionHeight = viewModel.size(forWidth: view.frame.width).height + 80
        
        if currentDataSource[indexPath.row].isReply {
            captionHeight = captionHeight + 20
        }
        
        return CGSize(width: view.frame.width, height: captionHeight)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: view.frame.width, height: 120)
//    }
}

// MARK: UICollectionViewDelegate

extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: profileHeader, for: indexPath) as! ProfileHeader
        header.user = user
        header.delegate = self
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = TweetController(tweet: currentDataSource[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: ProfileHeaderDelegate

extension ProfileController: ProfileHeaderDelegate {
    
    func handleBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    func handleEditProfileFollow(_ header: ProfileHeader) {
        
        if user.isCurrentUser {
            let controller = EditProfileController(user: user)
            controller.delegate = self
            let navigation = UINavigationController(rootViewController: controller)
            navigation.modalPresentationStyle = .fullScreen
            present(navigation, animated: true, completion: nil)
            return
            
        } else {
            
            if user.isFollowed {
                
                UserService.shared.unfollowUser(uid: user.uid) { (error, ref) in
                    self.user.isFollowed = false
                    self.collectionView.reloadData()
                }
                
            } else {
                
                UserService.shared.followUser(uid: user.uid) { (error, ref) in
                    self.user.isFollowed = true
                    self.collectionView.reloadData()
                    
                    NotificationService.shared.uploadNotification(toUser: self.user, type: .follow)
                }
                
            }
            
        }

    }
    
    func didSelect(filter: ProfileFilterOptions) {
        print("Did select filter \(filter.description) in profile controller")
        self.selectedFilter = filter
    }
}

// MARK: EditProfileControllerDelegate

extension ProfileController: EditProfileControllerDelegate {
    
    func handleLogout() {
        do {
            try Auth.auth().signOut()
            let nav = UINavigationController(rootViewController: LoginController())
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            print("Did logout user")
        } catch let error {
            print("Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    func controller(_ controller: EditProfileController, updated user: User) {
        print("ProfileController open")
        controller.dismiss(animated: true, completion: nil)
        self.user = user
        self.collectionView.reloadData()
    }
    
}
