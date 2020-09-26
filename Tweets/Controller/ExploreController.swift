//
//  ExploreController.swift
//  Tweets
//
//  Created by Pedro Barbosa on 23/05/20.
//  Copyright © 2020 Pedro Barbosa. All rights reserved.
//

import UIKit

private let userID = "userID"

enum SearchControllerConfiguration {
    case messages
    case users
}

class ExploreController: UITableViewController {
    
    // MARK: Properties
    
    private let config: SearchControllerConfiguration
    
    private var users = [User]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var filteredUsers = [User]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var inSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: Lifecycle
    
    init(config: SearchControllerConfiguration) {
        self.config = config
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchUsers()
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: API Service
    
    func fetchUsers() {
        UserService.shared.fetchUsers { users in
            self.users = users
        }
    }
    
    // MARK: Selectors
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        
        navigationItem.title = config == .messages ? "New Message" : "Explore"
        
        tableView.register(UserCell.self, forCellReuseIdentifier: userID)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        
        if config == .messages {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
        }
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a user"
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
}

// MARK: UITableViewDelegate/Datasource

extension ExploreController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filteredUsers.count : users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: userID, for: indexPath) as! UserCell
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        cell.user = user
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: UISearchResultsUpdating

extension ExploreController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        
        filteredUsers = users.filter({$0.username.contains(searchText) || $0.fullname.contains(searchText)})
    }
}
