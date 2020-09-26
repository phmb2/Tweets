//
//  UserCell.swift
//  Tweets
//
//  Created by Pedro Barbosa on 13/06/20.
//  Copyright © 2020 Pedro Barbosa. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    // MARK: Properties
    
    var user: User? {
        didSet {
            configure()
        }
    }
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.setDimensions(width: 42, height: 42)
        imageView.layer.cornerRadius = 42 / 2
        imageView.backgroundColor = .twitterBlue
        
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "Username"
        return label
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Fullname"
        return label
    }()
    
    // MARK: Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        
        let stackView = UIStackView(arrangedSubviews: [usernameLabel, fullnameLabel])
        stackView.axis = .vertical
        stackView.spacing = 3
        
        addSubview(stackView)
        stackView.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Helpers
    
    func configure() {
        guard let user = user else { return }
        
        profileImageView.sd_setImage(with: user.profileImageUrl)
        usernameLabel.text = user.username
        fullnameLabel.text = user.fullname
    }
}


