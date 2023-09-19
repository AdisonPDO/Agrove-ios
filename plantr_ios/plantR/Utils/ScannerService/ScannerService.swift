//
//  UserService.swift
//  TED Orthopedics
//
//  Created by Sebastien  Fourtou on 1/19/19.
//  Copyright © 2019 TEDOrtho. All rights reserved.
//

import Foundation

class ScannerService {
    
    static let shared = ScannerService()
    
    var showScanner: Bool = false
    var showLinksGardener: Bool = false
    var showGoToSubscribe: Bool = false
    var gardener: GardenerModel? = nil
    
    func reset() {
        showScanner = false
        showLinksGardener = false
        gardener = nil
    }
}
