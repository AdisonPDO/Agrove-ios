//
//  LiveObjectService.swift
//  plantR_ios
//
//  Created by Adison Pereira de oliveira on 29/04/2022.
//  Copyright © 2022 Agrove. All rights reserved.
//

import Foundation

struct EditConfigResult: Decodable {
    let id: String
    let data: String
    let port: Int
    let confirmed: Bool
    let commandStatus: String
    let creationTs: String
    let updateTs: String
}

struct Config: Decodable {
    let id: String
    let data: String
    let port: Int
    let confirmed: Bool
}

class LiveObjectService {
    let url = "https://liveobjects.orange-business.com/"
    let apiKey = "4855f5c1e92647d7989c31b1197b466f"
    
    func sendConfig(config : Config){
        let completeUrl = NSURL(string: "\(self.url)api/v0/vendors/lora/devices/\(config.id)/commands")
//        let request = NSMutableURLRequest(URL: completeUrl as! URL)
        
        
        
    }
}
