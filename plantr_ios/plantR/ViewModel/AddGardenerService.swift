//
//  AddGardenerViewModel.swift
//  plantR_ios
//
//  Created by Boris Roussel on 25/05/2021.
//  Copyright © 2021 Agrove. All rights reserved.
//

class AddGardenerService {
    
    static let shared = AddGardenerService()
    
    var kitAgrove = false
    var selectingTypeStruct: SelectingTypeStruct?
    var sizeType: SizeSelectingType?
    
    func getType() -> String? {
        switch AddGardenerService.shared.selectingTypeStruct?.type {
        case GardenerType.KitCapteur:
            return "kit_capteur"
        case GardenerType.Carre:
            return "carre"
        case GardenerType.Jardinière:
            return "jardiniere"
        case GardenerType.Pot:
            return "pot"
        default:
            return nil
        }
    }
    
    func getDimension() -> Int? {
        //print("getDimension => \(AddGardenerService.shared.sizeType)")
        switch AddGardenerService.shared.sizeType {
        case .potPetit, .jardinierePetite, .carrePetit:
            //print("dimens => 0")
            return 0
        case .potMoyen, .jardiniereMoyen, .carreMoyen:
            //print("dimens => 1")
            return 1
        case .potGrand, .jardiniereGrand, .carreGrand:
            //print("dimens => 2")
            return 2
        default:
            return 2
        }
    }
    
    func getStage(_ dimension: Int) -> String? {
        switch AddGardenerService.shared.sizeType {
        case .potPetit, .potMoyen, .potGrand, .jardinierePetite, .jardiniereMoyen, .jardiniereGrand:
            return "1"
        case .carrePetit, .carreMoyen, .carreGrand:
            switch dimension {
            case 0:
                return "2"
            case 1:
                return "3"
            case 2:
                return "4"
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    func reset() {
        kitAgrove = false
        selectingTypeStruct = nil
        sizeType = nil
    }
}
