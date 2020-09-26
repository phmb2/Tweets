//
//  NotificationsController.swift
//  Tweets
//
//  Created by Pedro Barbosa on 23/05/20.
//  Copyright © 2020 Pedro Barbosa. All rights reserved.
//

import UIKit

private let notificationCell = "NotificationCell"

class NotificationsController: UITableViewController {
    
    // MARK: Properties
    
    private var notifications = [Notification]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    
    // MARK: API Service
    
    func fetchNotifications() {
        refreshControl?.beginRefreshing()
        NotificationService.shared.fetchNotifications { notifications in
            self.refreshControl?.endRefreshing()
            self.notifications = notifications
            self.checkIfUserIsFollowed(notifications: notifications)
        }
    }
    
    func checkIfUserIsFollowed(notifications: [Notification]) {
        guard !notifications.isEmpty else { return }
        
        notifications.forEach { notification in
            
            guard case .follow = notification.type else { return }
            
            let user = notification.user
            
            UserService.shared.checkUserIsFollowed(uid: user.uid) { userIsFollowed in
                if let index = self.notifications.firstIndex(where: { $0.user.uid == notification.user.uid }) {
                    self.notifications[index].user.isFollowed = userIsFollowed
                }
            }
        }
    }
    
    // MARK: Selectors
    
    @objc func handleRefresh() {
        fetchNotifications()
    }
    
    // MARK: Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        
        navigationItem.title = "Notifications"
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: notificationCell)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
}

// MARK: UITableViewDataSource

extension NotificationsController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: notificationCell, for: indexPath) as! NotificationCell
        cell.notification = notifications[indexPath.row]
        cell.delegate = self
        return cell
    }
}

// MARK: UITableViewDelegate

extension NotificationsController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        
        guard let tweetId = notification.tweetId else { return }
        
        TweetService.shared.fetchTweet(withTweetId: tweetId) { tweet in
            let controller = TweetController(tweet: tweet)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

// MARK: NotificationCellDelegate

extension NotificationsController: NotificationCellDelegate {
    
    func didTapProfileImage(_ cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapFollow(_ cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        
        if user.isFollowed {
            UserService.shared.unfollowUser(uid: user.uid) { (error, ref) in
                cell.notification?.user.isFollowed = false
            }
        } else {
            UserService.shared.followUser(uid: user.uid) { (error, ref) in
                cell.notification?.user.isFollowed = true
            }
        }
    }
    
}
