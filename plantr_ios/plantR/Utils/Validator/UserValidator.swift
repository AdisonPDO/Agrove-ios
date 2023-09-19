//
//  UserValidator.swift
//  plantR_ios
//
//  Created by Rabissoni on 21/01/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import Foundation

class UserValidator {
    
    let errorMessage: String?
    
    init(firstname: String, lastname: String, email: String, password: String?, confirmPassword: String?, currentPassword: String? = " ") {
        if firstname == "" || lastname == "" || email == "" || (currentPassword != "" && (confirmPassword == "" || password == "") || password != "" && currentPassword == "") {
            errorMessage = "Veuillez remplir tous les champs"
        } else if password != confirmPassword {
            errorMessage = "Les mots de passe ne sont pas identiques"
        } else {
            errorMessage = nil
        }
    }
}
