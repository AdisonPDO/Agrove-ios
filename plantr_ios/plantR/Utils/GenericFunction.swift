//
//  GenericFunction.swift
//  plantR_ios
//
//  Created by Boris Roussel on 26/03/2021.
//  Copyright © 2021 Agrove. All rights reserved.
//

import UIKit

func checkBetweenStartAndEnd(start: Int, end: Int, current: Int) -> Bool {
    
    if end <= start {
        return current >= start && current <= 12 || current >= 1 && current <= end
    } else {
        return current >= start && current <= end
    }
}

func setupClassicCarreImage(stage: String, dimension: Int, image: UIImageView) {
    switch stage {
    case "2":
        image.image = UIImage(named: "petit_carre_potager")
    case "3":
        image.image = UIImage(named: "moyen_carre_potager")
    case "4":
        image.image = UIImage(named: "grand_carre_potager")
    default:
        image.image = UIImage(named: "grand_carre_potager")
    }
}

func setupClassicCarreImageWhite(stage: String, dimension: Int, image: UIImageView) {
    switch stage {
    case "2":
        image.image = UIImage(named: "petit_carre_potager_blanc")
    case "3":
        image.image = UIImage(named: "moyen_carre_potager_blanc")
    case "4":
        image.image = UIImage(named: "grand_carre_potager_blanc")
    default:
        image.image = UIImage(named: "grand_carre_potager_blanc")
    }
}

func setupClassicCarreImageVert(stage: String, dimension: Int, image: UIImageView) {
    switch stage {
    case "2":
        image.image = UIImage(named: "petit_carre_potager")
    case "3":
        image.image = UIImage(named: "moyen_carre_potager")
    case "4":
        image.image = UIImage(named: "grand_carre_potager")
    default:
        image.image = UIImage(named: "grand_carre_potager")
    }
}


func setupClassicPotImage(stage: String, dimension: Int, image: UIImageView) {
    switch dimension {
    case 0:  image.image = UIImage(named: "pot_petit_taille")
    case 1:  image.image = UIImage(named: "pot_moyen_taille")
    case 2:  image.image = UIImage(named: "pot_grand_taille")
    default:
        image.image = UIImage(named: "pot_grand_taille")
    }
}

func setupClassicPotImageWhite(stage: String, dimension: Int, image: UIImageView) {
    switch dimension {
    case 0:  image.image = UIImage(named: "pot_petit_blanc")
    case 1:  image.image = UIImage(named: "pot_moyen_blanc")
    case 2:  image.image = UIImage(named: "pot_grand_blanc")
    default:
        image.image = UIImage(named: "pot_grand_blanc")
    }
}

func setupClassicPotImageVert(stage: String, dimension: Int, image: UIImageView) {
    switch dimension {
    case 0:  image.image = UIImage(named: "petit_pot_vert")
    case 1:  image.image = UIImage(named: "pot_moyen_vert")
    case 2:  image.image = UIImage(named: "pot_grand_vert")
    default:
        image.image = UIImage(named: "pot_grand_taille")
    }
}

func setupClassicGardenerImage(stage: String, dimension: Int, image: UIImageView) {
    switch dimension {
    case 0: image.image = UIImage(named: "jardiniere_petit_taille")
    case 1: image.image = UIImage(named: "jardiniere_moyen_taille")
    case 2: image.image = UIImage(named: "jardiniere_grand_taille")
    default:
        image.image = UIImage(named: "jardiniere_grand_taille")
    }
}

func setupClassicGardenerImageWhite(stage: String, dimension: Int, image: UIImageView) {
    
    switch dimension {
    case 0: image.image = UIImage(named: "jardiniere_petit_blanc")
    case 1: image.image = UIImage(named: "jardiniere_moyen_blanc")
    case 2: image.image = UIImage(named: "jardiniere_grand_blanc")
    default:
        image.image = UIImage(named: "jardiniere_grand_blanc")
    }
}

func setupClassicGardenerImageVerte(stage: String, dimension: Int, image: UIImageView) {
    
    switch dimension {
    case 0: image.image = UIImage(named: "jardiniere_petit_vert")
    case 1: image.image = UIImage(named: "jardiniere_moyen_verte")
    case 2: image.image = UIImage(named: "jardiniere_grand_vert")
    default:
        image.image = UIImage(named: "jardiniere_grand_vert")
    }
}

func setupCapteurPotImageWhite(stage: String, dimension: Int, image: UIImageView) {
    switch dimension {
    case 0:  image.image = UIImage(named: "kit_capteur_pot_petit")
    case 1:  image.image = UIImage(named: "kit_capteur_pot_moyen")
    case 2:  image.image = UIImage(named: "kit_capteur_pot_grand")
    default:
        image.image = UIImage(named: "kit_capteur_pot_grand")
    }
}
func setupCapteurPotImageVert(stage: String, dimension: Int, image: UIImageView) {
    switch dimension {
    case 0:  image.image = UIImage(named: "capteur_pot_vert_petit")
    case 1:  image.image = UIImage(named: "capteur_pot_vert_moyen")
    case 2:  image.image = UIImage(named: "capteur_pot_vert_grand")
    default:
        image.image = UIImage(named: "capteur_pot_vert_grand")
    }
}

func setupCapteurGardenerImageWhite(stage: String, dimension: Int, image: UIImageView) {
    switch dimension {
    case 0: image.image = UIImage(named: "kit_capteur_jardiniere_petit")
    case 1: image.image = UIImage(named: "kit_capteur_jardiniere_moyen")
    case 2: image.image = UIImage(named: "kit_capteur_jardiniere_grand")
    default:
        image.image = UIImage(named: "kit_capteur_jardiniere_grand")
    }
}

func setupCapteurGardenerImageVert(stage: String, dimension: Int, image: UIImageView) {
    switch dimension {
    case 0: image.image = UIImage(named: "capteur_jardiniere_vert_petit")
    case 1: image.image = UIImage(named: "capteur_jardiniere_vert_moyen")
    case 2: image.image = UIImage(named: "capteur_jardiniere_vert_grand")
    default:
        image.image = UIImage(named: "capteur_jardiniere_vert_grand")
    }
}

func setupGardenerImageWhite(stage: String, dimension: Int, image: UIImageView) {
    switch stage {
    case "2": image.image = UIImage(named: "kit_2_etage")
    case "3": image.image = UIImage(named: "kit_3_etages")
    case "4": image.image = UIImage(named: "kit_4_etages")
    default:
        image.image = UIImage(named: "kit_4_etages")
    }
}
func setupGardenerImageVert(stage: String, dimension: Int, image: UIImageView) {
    print("stage => \(stage)")
    switch stage {
    case "2":
        print("2 ETAGE IMAGE GREEN")
        image.image = UIImage(named: "kit_2etages_vert")
    case "3":
        print("3 ETAGE IMAGE GREEN")
        image.image = UIImage(named: "kit_3etages_vert")
    case "4":
        print("4 ETAGE IMAGE GREEN")
        image.image = UIImage(named: "kit_4etages_vert")
    default:
        print("DEFAULT ETAGE IMAGE GREEN")
        image.image = UIImage(named: "kit_4etages_vert")
    }
}

func setupParcelImageVert(stage: String, dimension: Int, image: UIImageView) {
    print("stage => \(stage)")
    switch stage {
    case "2":
        print("2 ETAGE IMAGE GREEN")
        image.image = UIImage(named: "kit_2etages_vert")
    case "3":
        print("3 ETAGE IMAGE GREEN")
        image.image = UIImage(named: "kit_3etages_vert")
    case "4":
        print("4 ETAGE IMAGE GREEN")
        image.image = UIImage(named: "kit_4etages_vert")
    default:
        print("DEFAULT ETAGE IMAGE GREEN")
        image.image = UIImage(named: "kit_4etages_vert")
    }
}

func setupCapteurCarreImageVert(stage: String, dimension: Int, image: UIImageView) {
    switch dimension {
    case 0: image.image = UIImage(named: "capteurcarre_petit_vert")
    case 1: image.image = UIImage(named: "capteurcarre_moyen_vert")
    case 2: image.image = UIImage(named: "capteurcarre_grand_vert")
    default:
        image.image = UIImage(named: "capteurcarre_grand_vert")
    }
}

func setupCapteurCarreImageBlanc(stage: String, dimension: Int, image: UIImageView) {
    switch dimension {
    case 0: image.image = UIImage(named: "capteurcarre_petit_blanc")
    case 1: image.image = UIImage(named: "capteurcarre_moyen_blanc")
    case 2: image.image = UIImage(named: "capteurcarre_grand_blanc")
    default:
        image.image = UIImage(named: "capteurcarre_grand_blanc")
    }
}

func setupMuralGardenerImageWhite(stage: String, dimension: Int, image: UIImageView) {
    image.image = UIImage(named: "kit_mural_home")
}
func setupMuralGardenerImageVert(stage: String, dimension: Int, image: UIImageView) {
    image.image = UIImage(named: "kit_mural_vert")
}


func setImageGenericGardener(gardener: GardenerModel, ivCenter: UIImageView) {
    switch gardener.type {
    case "pot":
        setupClassicPotImage(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    case "capteur_pot":
        setupCapteurPotImageWhite(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    case "carre":
        setupClassicCarreImage(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    case "jardiniere":
        setupClassicGardenerImage(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    case "capteur_jardiniere":
        setupCapteurGardenerImageWhite(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    case "cle_en_main":
        setupGardenerImageWhite(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    case "mural":
        setupMuralGardenerImageWhite(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    case "capteur_carre":
        setupCapteurCarreImageBlanc(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    default:
        setupGardenerImageWhite(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    }
}

func setImageGenericGardenerWhite(gardener: GardenerModel, ivCenter: UIImageView) {
    switch gardener.type {
    case "pot":
        setupClassicPotImageWhite(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    case "capteur_pot":
        setupCapteurPotImageWhite(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    case "carre":
        setupClassicCarreImageWhite(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    case "jardiniere":
        setupClassicGardenerImageWhite(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    case "capteur_jardiniere":
        setupCapteurGardenerImageWhite(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    case "cle_en_main":
        setupGardenerImageWhite(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    case "mural":
        setupMuralGardenerImageWhite(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    case "capteur_carre":
        setupCapteurCarreImageBlanc(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    default:
        setupGardenerImageWhite(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    }
}

func setImageGenericGardenerGreen(gardener: GardenerModel, ivCenter: UIImageView) {
    print("gardenerType => \(gardener.type)")
    switch gardener.type {
    case "pot":
        setupClassicPotImageVert(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    case "capteur_pot":
        setupCapteurPotImageVert(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    case "carre":
        setupClassicCarreImageVert(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    case "jardiniere":
        setupClassicGardenerImageVerte(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    case "capteur_jardiniere":
        setupCapteurGardenerImageVert(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    case "cle_en_main":
        setupGardenerImageVert(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    case "mural":
        setupMuralGardenerImageVert(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    case "parcelle":
        setupParcelImageVert(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    case "capteur_carre":
        setupCapteurCarreImageVert(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    default:
        setupGardenerImageVert(stage: gardener.stage, dimension: gardener.dimension, image: ivCenter)
    }
}

func setImageGenericPlantsVC(gardener: GardenerModel, ivCenter: UIImageView) {
    switch gardener.type {
    case "pot":
        ivCenter.image = UIImage(named: "mes_plantes_pot_gris")
    case "capteur_pot":
        ivCenter.image = UIImage(named: "capteur_pot_gris")
    case "jardiniere":
        ivCenter.image = UIImage(named: "jardiniere_gris")
    case "capteur_jardiniere":
        ivCenter.image = UIImage(named: "capteur_jardiniere_gris")
    case "mural":
        ivCenter.image = UIImage(named: "kit_mural_gris")
    default:
        break
    }
}


func setFormatKeyForRangInParcelle(rang: Int, _ gardener: GardenerModel, label: UILabel) {
    if gardener.rangs == 2 {
        switch rang {
        case 0:
            label.text = "Premier"
        case 1:
            label.text = "Deuxième"
        default:
            label.text = ""
        }
    }
    if gardener.rangs == 1 {
        switch rang {
        case 0:
            label.text = "Premier"
        default:
            label.text = ""
        }
    }
}

func setFormatKeyForStage(stage: Character, _ gardener: GardenerModel, label: UILabel) {
    if gardener.stage == "4" {
        switch stage {
        case "0":
            label.text = NSLocalizedString("fourth", comment: "fourth")
        case "1":
            label.text = NSLocalizedString("third", comment: "third")
        case "2":
            label.text = NSLocalizedString("second", comment: "second")
        case "3":
            label.text = NSLocalizedString("first", comment: "first")
        default:
            label.text = ""
        }
    }
    if gardener.stage == "3" {
        switch stage {
        case "0":
            label.text = NSLocalizedString("third", comment: "third")
        case "1":
            label.text = NSLocalizedString("second", comment: "second")
        case "2":
            label.text = NSLocalizedString("first", comment: "first")
        default:
            label.text = ""
        }
    }
    if gardener.stage == "2" {
        switch stage {
        case "0":
            label.text = NSLocalizedString("second", comment: "second")
        case "1":
            label.text = NSLocalizedString("first", comment: "first")
        default:
            label.text = ""
        }
    }
    if gardener.stage == "1" {
        switch stage {
        case "0":
            label.text = NSLocalizedString("first", comment: "first")
        default:
            label.text = ""
        }
    }
    
}

func setPotRowDimension(dimension: Int) -> Int {
    switch dimension {
    case 0: return 1
    case 1: return 1
    case 2: return 1
    default: return 1
    }
}
func setJardiniereRowDimension(dimension: Int) -> Int {
    switch dimension {
    case 0: return 2
    case 1: return 4
    case 2: return 4
    default: return 4
    }
}
func setSquareRowDimension(dimension: Int) -> Int {
    switch dimension {
    case 0: return 2
    case 1: return 3
    case 2: return 4
    default: return 4
    }
}

func isGardenerAgrove(_ gardener: GardenerModel) -> Bool {
    if (gardener.id.contains("Classic")) {
        return false
    }
    return true
}

func setNumberOfRowOfType(_ gardener: GardenerModel) -> Int {
    switch gardener.type {
    case "pot":
        return 1
    case "capteur_pot":
        return 1
    case "carre":
        return setSquareRowDimension(dimension: gardener.dimension)
    case "capteur_carre":
        return setSquareRowDimension(dimension: gardener.dimension)
    case "jardiniere":
        return setJardiniereRowDimension(dimension: gardener.dimension)
    case "capteur_jardiniere":
        return setJardiniereRowDimension(dimension: gardener.dimension)
    case "cle_en_main":
        return 4
    case "mural":
        return 4
    default:
        return 4
    }
}

func convertStringToDate(dateString: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    let date = dateFormatter.date(from: dateString)
    dateFormatter.dateFormat = "dd/MM/yyyy"
    return dateFormatter.string(from: date!)
}

func parseTimestampToDateString(timestamp: Int) -> String {
    let date = NSDate(timeIntervalSince1970: Double(timestamp))
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy 'T' HH:mm"
    return dateFormatter.string(from: date as Date)
}

func isOlderThanTwoDays(timestamp: Int) -> Bool {
    if(timestamp == 0){
        return false
    }else{
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date, to: Date())
        return components.day! > 2
    }
}

func parseTimestamp(timestamp: String) -> Int {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    let date = dateFormatter.date(from: timestamp)
    return Int(date!.timeIntervalSince1970)
}
