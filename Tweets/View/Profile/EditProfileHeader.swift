//
//  EditProfileHeader.swift
//  Tweets
//
//  Created by Pedro Barbosa on 19/08/20.
//  Copyright © 2020 Pedro Barbosa. All rights reserved.
//

import UIKit

protocol EditProfileHeaderDelegate: class {
    func didChangeProfilePhoto()
}

class EditProfileHeader: UIView {
    
    // MARK: Properties
    
    private let user: User
    
    weak var delegate: EditProfileHeaderDelegate?
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        return imageView
    }()
    
    private let changePhotoButton: UIButton = {
         let button = UIButton()
         button.setTitle("Change Profile Photo", for: .normal)
         button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
         button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleChangeProfilePhoto), for: .touchUpInside)
         return button
    }()
    
    // MARK: Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(frame: .zero)
        
        backgroundColor = .twitterBlue
        
        addSubview(profileImageView)
        profileImageView.center(inView: self, yConstant: -16)
        profileImageView.setDimensions(width: 100, height: 100)
        profileImageView.layer.cornerRadius = 100 / 2
        
        addSubview(changePhotoButton)
        changePhotoButton.centerX(inView: self, topAnchor: profileImageView.bottomAnchor, paddingTop: 8)
        
        profileImageView.sd_setImage(with: user.profileImageUrl)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Selectors
    
    @objc func handleChangeProfilePhoto() {
        delegate?.didChangeProfilePhoto()
    }
    
    // MARK: Helpers
}
