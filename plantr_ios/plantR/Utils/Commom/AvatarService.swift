//
//  ServiceNotifcationCenter.swift
//  plantR_ios
//
//  Created by Boris Roussel on 15/03/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseUI

class AvatarService {
    
    static let avatarUpdatedNotification = Notification.Name("AvatarUpdated")
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func updateCurrentUserImageProfile(_ image: UIImage) {
        guard let currentUser = Auth.auth().currentUser, let data = image.jpegData(compressionQuality: 0.4) else { return }
        let userImageProfileRef = userRepository.getImageProfile(for: currentUser.uid)

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        userImageProfileRef.putData(data, metadata: metadata) { (metadata, error) in
                var url = NSURL.sd_URL(with: userImageProfileRef)
                SDImageCache.shared.store(image, forKey: url?.absoluteString) {
                    NotificationCenter.default.post(name: AvatarService.avatarUpdatedNotification, object: nil)
                }
                NotificationCenter.default.post(name: AvatarService.avatarUpdatedNotification, object: nil)
        }
    }
}
