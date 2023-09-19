//
//  BranchService.swift
//  plantR_ios
//
//  Created by Boris Roussel on 31/08/2020.
//  Copyright © 2020 Rabissoni. All rights reserved.
//

import Foundation

class BranchService {
    
    static let shared = BranchService()
    
    var branchGoToOwner = false
    var branchGoToGuest = false
    var gardenerName: String?
    var branchId: String?
    
    var notificationTest: String? = "NULL"
    
    func reset() {
        branchGoToOwner = false
        branchGoToGuest = false
        branchId = nil
        gardenerName = nil
    }
}
