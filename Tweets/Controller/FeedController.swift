//
//  FeedController.swift
//  Tweets
//
//  Created by Pedro Barbosa on 23/05/20.
//  Copyright © 2020 Pedro Barbosa. All rights reserved.
//

import UIKit
import SDWebImage

private let tweetID = "tweetID"

class FeedController: UICollectionViewController {
    
    // MARK: Properties
    
    var user: User? {
        didSet {
            configureLeftBarButton()
        }
    }
    
    private var tweets = [Tweet]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        configureUI()
        fetchTweets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: API Service
    
    func fetchTweets() {
        collectionView.refreshControl?.beginRefreshing()
        
        TweetService.shared.fetchTweets { tweets in
            self.tweets = tweets.sorted(by: { $0.timestamp > $1.timestamp })
            self.checkUserLikedTweet()
                
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    func checkUserLikedTweet() {
        self.tweets.forEach { tweet in
            TweetService.shared.checkUserLikedTweet(tweet) { didLike in
                guard didLike == true else { return }
                
                if let index = self.tweets.firstIndex(where: { $0.tweetId == tweet.tweetId }) {
                    self.tweets[index].didLike = true
                }
            }
        }
    }
    
    // MARK: Selectors
    
    @objc func handleRefresh() {
        fetchTweets()
    }
    
    @objc func handleProfileImageTap() {
        guard let user = user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: Helpers
    
    func configureUI() {
        
        view.backgroundColor = .white
        
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: tweetID)
        collectionView.backgroundColor = .white
        
        let headerImageView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        headerImageView.contentMode = .scaleAspectFit
        headerImageView.setDimensions(width: 44, height: 44)
        navigationItem.titleView = headerImageView
        
        let refreshControl = UIRefreshControl()
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    func configureLeftBarButton() {
        guard let user = user else { return }
        
        let profileImageView = UIImageView()
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        profileImageView.layer.masksToBounds = true
        profileImageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTap))
        profileImageView.addGestureRecognizer(tap)
        
        profileImageView.sd_setImage(with: user.profileImageUrl, completed: nil)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }
}

// MARK: UICollectionViewDelegate/Datasource

extension FeedController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tweetID, for: indexPath) as! TweetCell
        cell.delegate = self
        cell.tweet = tweets[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = TweetController(tweet: tweets[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension FeedController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = TweetViewModel(tweet: tweets[indexPath.row])
        let captionHeight = viewModel.size(forWidth: view.frame.width).height
        return CGSize(width: view.frame.width, height: captionHeight + 80)
    }
}

// MARK: TweetCellDelegate

extension FeedController: TweetCellDelegate {
    
    func handleProfileImageTapped(_ cell: TweetCell) {
        
        guard let user = cell.tweet?.user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func handleReplyTapped(_ cell: TweetCell) {
        
        guard let tweet = cell.tweet else { return }
        let controller = UploadTweetController(user: tweet.user, config: .reply(tweet))
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    func handleLikeTapped(_ cell: TweetCell) {
        
        guard let tweet = cell.tweet else { return }
        
        TweetService.shared.likeTweet(tweet: tweet) { (error, ref) in
            cell.tweet?.didLike.toggle()
            let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
            cell.tweet?.likes = likes
            
            // Only upload notification if tweet is being liked
            guard !tweet.didLike else { return }
            NotificationService.shared.uploadNotification(toUser: tweet.user, type: .like, tweetId: tweet.tweetId)
        }
    }
    
    func handleShareTapped(_ cell: TweetCell) {
        
        guard let tweet = cell.tweet else { return }
        
        // Set up activity view controller
        let textToShare = [ tweet.caption ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // So that iPads won't crash

        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook, UIActivity.ActivityType.postToTwitter ]

        // Present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func handleFetchUser(withUsername username: String) {
        
        UserService.shared.fetchUser(withUsername: username) { user in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
