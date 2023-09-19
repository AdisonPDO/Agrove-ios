//
//  SSID.swift
//  plantR_ios
//
//  Created by Rabissoni on 21/01/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import Foundation
import SystemConfiguration
import SystemConfiguration.CaptiveNetwork

class SSID {
    
    class func fetchSSIDInfo() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
    }
}
