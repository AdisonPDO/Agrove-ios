//
//  WishlistAwailableDataSource.swift
//  plantR_ios
//
//  Created by Boris Roussel on 26/03/2021.
//  Copyright © 2021 Agrove. All rights reserved.
//

import UIKit

class WishlistNotAwailableViewModel {
    
    //MARK: Attributes
    
    var plantNotAwailable: [(plantName: String, plantInfo: InfosPlants, dateOk: WishlistModel)] = []
}

class WishlistNotAwailableDataSource: NSObject {
    
    var wishlistNotAwailableViewModel: WishlistNotAwailableViewModel!
    
}


extension WishlistNotAwailableDataSource: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard self.wishlistNotAwailableViewModel != nil else {
            return 0
        }
        return self.wishlistNotAwailableViewModel.plantNotAwailable.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        print("* REFRESH NOT AWAILABLE *")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantsCell", for: indexPath) as! AddPlantCVC
        let plantPath = self.wishlistNotAwailableViewModel.plantNotAwailable[indexPath.row]
        cell.imageViewPlant.sd_setImage(with: plantPath.plantInfo.imagePlant)
        cell.titleLabel.text = plantPath.plantInfo.infoPlant.name

        let date = Date()
        let dateComponent = Calendar.current.dateComponents([.month], from: date)
        
        guard let currentlyMonth = dateComponent.month else { return cell }
        let sowingState = checkBetweenStartAndEnd(start: plantPath.dateOk.sowingPeriod.startMonth, end: plantPath.dateOk.sowingPeriod.endMonth, current: currentlyMonth)
        let plantingState = checkBetweenStartAndEnd(start: plantPath.dateOk.plantingPeriod.startMonth, end: plantPath.dateOk.plantingPeriod.endMonth, current: currentlyMonth)
        
        if (sowingState && !plantingState) {
            cell.state = .sowing
            cell.vInfo.isHidden = false
            cell.stateInfoLabel.text = NSLocalizedString("sow", comment: "sow your plant")
        } else if (!sowingState && plantingState) {
            cell.state = .planting
            cell.vInfo.isHidden = false
            cell.stateInfoLabel.text =  NSLocalizedString("plant", comment: "plant your plant")
        } else if (sowingState && plantingState) {
            cell.state = .twice
            cell.stateInfoLabel.text =  NSLocalizedString("sow_or_plant_your", comment: "sow or plant your plant")
            cell.vInfo.isHidden = false
        } else {
            cell.state = .none
            cell.vInfo.isHidden = true
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 6.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! AddPlantCVC
        switch cell.state {
        case .planting:
            print("PLANTING")
        case .sowing:
            print("SOWING")
        case .twice:
            print("TWICE")
        default:
            print("NONE")
        }
/*        if let key = key {
            let controller = StoryboardScene.MyPlants.changeNameVC.instantiate()
            controller.plant =  plantTuples[indexPath.row]
            controller.key = key
            controller.gardenerId = gardenerId
            present(controller, animated: true, completion: nil)
        }*/
    }

    
}
