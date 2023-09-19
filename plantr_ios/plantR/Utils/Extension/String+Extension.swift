//
//  String+Extension.swift
//  plantR_ios
//
//  Created by Boris Roussel on 11/05/2021.
//  Copyright © 2021 Agrove. All rights reserved.
//

import Foundation

extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
    func trimmingLeadingAndTrailingSpaces(using characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        return trimmingCharacters(in: characterSet)
    }
}
