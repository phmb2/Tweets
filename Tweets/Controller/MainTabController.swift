//
//  MainTabController.swift
//  Tweets
//
//  Created by Pedro Barbosa on 23/05/20.
//  Copyright © 2020 Pedro Barbosa. All rights reserved.
//

import UIKit
import Firebase

enum ActionButtonConfiguration {
    case tweet
    case message
}

class MainTabController: UITabBarController {
    
    // MARK: Properties
    
    private var buttonConfig: ActionButtonConfiguration = .tweet
    
    var user: User? {
        didSet {
            guard let nav = viewControllers?[0] as? UINavigationController else { return }
            guard let feed = nav.viewControllers.first as? FeedController else { return }
            
            feed.user = user
        }
    }
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = .twitterBlue
        button.setImage(UIImage(named: "new_tweet"), for: .normal)
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        //logoutUser()
        view.backgroundColor = .twitterBlue
        authenticateUserAndConfigureUI()
    }
    
    // MARK: API Service
    
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserService.shared.fetchUser(uid: uid) { user in
            self.user = user
        }
    }
    
    func authenticateUserAndConfigureUI() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            configureViewControllers()
            configureUI()
            fetchUser()
        }
    }
    
//    func logoutUser() {
//        do {
//            try Auth.auth().signOut()
//            print("Did logout user")
//        } catch let error {
//            print("Failed to sign out with error \(error.localizedDescription)")
//        }
//    }
    
    // MARK: Selectors
    
    @objc func actionButtonTapped() {
        
        let controller: UIViewController
        
        switch buttonConfig {
            case .message:
                controller = ExploreController(config: .messages)
            case .tweet:
                guard let user = user else { return }
                controller = UploadTweetController(user: user, config: .tweet)
        }
        
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    // MARK: Helpers
    
    func configureUI() {
        
        self.delegate = self
        
        view.addSubview(actionButton)
        
        actionButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingBottom: 64, paddingRight: 16, width: 56, height: 56)
        actionButton.layer.cornerRadius = 56/2
    }
    
    func configureViewControllers() {
        
        let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        let nav1 = templateNavigationController(image: UIImage(named: "home_unselected"), rootViewController: feed)
        
        let explore = ExploreController(config: .users)
        let nav2 = templateNavigationController(image: UIImage(named: "search_unselected"), rootViewController: explore)
        
        let notifications = NotificationsController()
        let nav3 = templateNavigationController(image: UIImage(named: "like_unselected"), rootViewController: notifications)
        
        let conversations = ConversationsController()
        let nav4 = templateNavigationController(image: UIImage(named: "ic_mail_outline_white_2x-1"), rootViewController: conversations)
        
        viewControllers = [nav1, nav2, nav3, nav4]
    }
    
    func templateNavigationController(image: UIImage?, rootViewController: UIViewController) -> UINavigationController {
        
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = image
        nav.navigationBar.barTintColor = .white
        
        return nav
    }

}

extension MainTabController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let index = viewControllers?.firstIndex(of: viewController)
        let image = index == 3 ? #imageLiteral(resourceName: "ic_mail_outline_white_2x-1") : #imageLiteral(resourceName: "new_tweet")
        actionButton.setImage(image, for: .normal)
        buttonConfig = index == 3 ? .message : .tweet
    }
}
