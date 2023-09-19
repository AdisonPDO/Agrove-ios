//
//  UserService.swift
//  plantR_ios
//
//  Created by Boris Roussel on 02/09/2020.
//  Copyright © 2020 Rabissoni. All rights reserved.
//

import Foundation

class UserService {
    
    static let shared = UserService()
    static let addGardenerNotification = Notification.Name("AddGardener")
    static let visitedUserNotification = Notification.Name("VisitedUser")
    static let refreshGardenerNotification = Notification.Name("RefreshGardener")

    var splashFirstLoad = false
    var branchEvent = false
    var visitedUser = false
}
