//
//  UtilsCategories.swift
//  plantR_ios
//
//  Created by Adison Pereira de oliveira on 04/03/2022.
//  Copyright © 2022 Agrove. All rights reserved.
//

import Foundation


struct UtilsCategories {
    func frToEn(str : String) -> String{
        switch(str.lowercased()){
        case("légumes"):
            return "Vegetables"
        case("fleurs"):
            return "Flowers"
        case("médicinales"):
            return "Medicinal"
        case("dépolluantes"):
            return "Depolluting"
        case("aromates"):
            return "Herbs"
        case("fruits"):
            return "Fruits"
        case("mellifères"):
            return "Melliferous"
        default:
            return "Vegetable"
        }
    }
    
    func enToFr(str : String) -> String{
        switch(str.lowercased()){
        case("vegetables"):
            return "Légumes"
        case("flowers"):
            return "Fleurs"
        case("medicinal"):
            return "Médicinales"
        case("depolluting"):
            return "Dépolluantes"
        case("herbs"):
            return "Aromates"
        case("fruits"):
            return "Fruits"
        case("melliferous"):
            return "Mellifères"
        default:
            return "Vegetable"
        }
    }
    
    func getTaskNameTrad(str: String) -> String {
        switch(str){
        case("Semer"):
            return NSLocalizedString("sow", comment: "sow")
        case("Planter"):
            return NSLocalizedString("plant", comment: "plant")
        default:
            return str
        }
    }
}
