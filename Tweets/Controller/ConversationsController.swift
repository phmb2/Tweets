//
//  ConversationsController.swift
//  Tweets
//
//  Created by Pedro Barbosa on 23/05/20.
//  Copyright © 2020 Pedro Barbosa. All rights reserved.
//

import UIKit

class ConversationsController: UIViewController {
    
    // MARK: Properties
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        
        navigationItem.title = "Messages"
    }
}
