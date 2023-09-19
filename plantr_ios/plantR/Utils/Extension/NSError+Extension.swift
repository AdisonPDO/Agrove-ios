//
//  NSError+Extension.swift
//  plantR_ios
//
//  Created by Rabissoni on 21/01/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import Foundation
import Firebase

extension Error {
    var localizedFirebaseAuthDescription: String {
        let nsError = self as NSError
        guard let code = AuthErrorCode(rawValue: nsError.code) else {
            return localizedDescription
        }
        switch code {
        case .emailAlreadyInUse:
            return "L'email est déja utilisé"
        case .invalidEmail:
            return "L'email est incorrect"
        case .invalidPhoneNumber:
            return "Le numero de telephone est invalide"
        case .missingEmail:
            return "Vous avez oublié l'adresse mail"
        case .missingPhoneNumber:
            return "Il manque votre numero de telephone"
        case .networkError:
            return "Probleme de reseau sur votre mobile"
        case .userNotFound:
            return "L'email est incorrect"
        case .weakPassword:
            return "Votre mot de passe est trop simple. Veuillez en utiliser un autre"
        case .wrongPassword:
            return "Mauvais mot de passe"
        default:
            return localizedDescription
        }
    }
}
