//
//  TipsAlert.swift
//  plantR_ios
//
//  Created by Boris on 07/05/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class TipsService {

    private let gardenerRepository: GardenerRepository
    init(gardenerRepository: GardenerRepository) {
        self.gardenerRepository = gardenerRepository
    }
    
    func checkWeatherToTips(climatDict: [String: Int], gardernerId: String) {
        let gardenerTipsRef = self.gardenerRepository.getGardenerTipsReference(by: gardernerId)

        for climat in climatDict {
            switch climat.key {
            case "wind":
                if climat.value > 49 {
                    gardenerTipsRef.child(climat.key).setValue(true)
                }
            case "temperature":
                if climat.value < 1 {
                    gardenerTipsRef.child(climat.key).setValue(true)
                }
            default:
                break
            }
        }
    }
    
    func getTipsBy(name: String) -> TipsType {
        switch name {
        case "soilMisture":
            return TipsType(name: "La terre est trop sèche !", description: "On est en reflexion sur le texte il sera à ajouter dès que la fonctionnalité réglage de l'irrigation sera fonctionnelle", goodTips: "L'eau coule", badTips: "L'eau ne coule pas")
        case "battery":
            return TipsType(name: "Chargez la batterie", description: "Placez le panneau solaire dans un environnement plus lumineux ou rechargez la batterie via une prise secteur ", goodTips: "Il est bien au soleil", badTips: "Il n'est pas bien placés")
        case "solarPower":
            return TipsType(name: "Manque de puissance dans la jardinière !", description: "Branche-la à l’électricité sur le port adéquat.", goodTips: "La jardinière est branchée", badTips: "Elle n'est pas branchée")
        case "waterLevel":
            return TipsType(name: "Remplissez le reservoir.", description: "Le niveau d'eau du réservoir est trop bas, pensez à en rajouter jusqu'au maximum.", goodTips: "C'est fait", badTips: "Je le ferai plus tard.")
        case "temperature":
            return TipsType(name: "Vérifier qu’il ne neige pas !", description: "Rentre ta jardinière,  si possible ou couvre la !", goodTips: "Elle est rentrée", badTips: "Pas encore rentrée")
        case "wind":
            return TipsType(name: "Vérifier qu’il y est pas un vent à plus de 50 km/h !", description: "Rentre ta jardinière, si possible ou couvre la !", goodTips: "Elle est rentrée", badTips: "Pas encore rentrée")
        case "panne":
            return TipsType(name: "Le capteur n'envoie plus de données depuis 24h", description: "Le capteur n'envoie plus de données depuis 24h", goodTips: "", badTips: "")
        default:
            return TipsType(name: "", description: "", goodTips: "", badTips: "")
        }
    }
    
    struct TipsType {
        let name: String
        let description: String
        let goodTips: String
        let badTips: String
    }
}
