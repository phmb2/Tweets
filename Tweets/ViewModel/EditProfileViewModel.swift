//
//  EditProfileViewModel.swift
//  Tweets
//
//  Created by Pedro Barbosa on 19/08/20.
//  Copyright © 2020 Pedro Barbosa. All rights reserved.
//

import Foundation

enum EditProfileOptions: Int, CaseIterable {
    case fullname
    case username
    case bio
    
    var description: String {
        switch self {
            case .fullname: return "Name"
            case .username: return "Username"
            case .bio: return "Bio"
        }
    }
}


struct EditProfileViewModel {
    
    private let user: User
    let option: EditProfileOptions
    
    init(user: User, option: EditProfileOptions) {
        self.user = user
        self.option = option
    }
    
    var optionLabel: String {
        return option.description
    }
    
    var optionValue: String? {
        switch option {
            case .fullname: return user.fullname
            case .username: return user.username
            case .bio: return user.bio
        }
    }
    
    var hideTextField: Bool {
        return option == .bio
    }
    
    var hideTextView: Bool {
        return option != .bio
    }
    
    var hidePlaceholderLabel: Bool {
        return user.bio != nil
    }
    
}
