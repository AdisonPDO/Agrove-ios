//
//  Date+extension.swift
//  plantR_ios
//
//  Created by Boris Roussel on 03/11/2020.
//  Copyright © 2020 Agrove. All rights reserved.
//

import Foundation

extension Date {

  var shortDate: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy"
    let strDate = formatter.string(from: self)
    return strDate
  }
}
