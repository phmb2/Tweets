//
//  EditProfileFooter.swift
//  Tweets
//
//  Created by Pedro Barbosa on 19/09/20.
//  Copyright © 2020 Pedro Barbosa. All rights reserved.
//

import UIKit

protocol EditProfileFooterDelegate: class {
    func handleLogout()
}

class EditProfileFooter: UIView {
    
    // MARK: Properties
    
    weak var delegate: EditProfileFooterDelegate?
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.backgroundColor = .red
        button.layer.cornerRadius = 6
        button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        return button
    }()
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(logoutButton)
        logoutButton.anchor(left: leftAnchor, right: rightAnchor, paddingLeft: 16, paddingRight: 16)
        logoutButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        logoutButton.centerY(inView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Selectors
    
    @objc func handleLogout() {
        delegate?.handleLogout()
    }
    
}
