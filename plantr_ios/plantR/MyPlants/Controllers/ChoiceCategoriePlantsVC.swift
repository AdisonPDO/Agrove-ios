//
//  ChoiceCategoriePlantsVC.swift
//  plantR_ios
//
//  Created by Boris Roussel on 04/12/2020.
//  Copyright © 2020 Agrove. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class ChoiceCategoriePlantsVC: UIViewController {

    @IBOutlet weak var searchLabel: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var key: String?
    var gardenerId: String?
    
    private var allPlantTuples: [(plantName: String, plantInfo: InfosPlants)] = []
    private var plantTuples: [(plantName: String, plantInfo: InfosPlants)] = []
    
    var plantsService: PlantsService!
    var plantRepository: PlantRepository!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.reloadData()
    }

    @IBAction func actionGoToAddPlant(_ sender: UIButton) {
        self.performSegue(withIdentifier: "actionToPlants", sender: nil)
    }
    
    @IBAction func filterPlantModel(_ sender: UITextField) {
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension ChoiceCategoriePlantsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plantsService.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantsCell", for: indexPath) as! AddPlantCVC
        var storageRef = self.plantRepository.getStorageImageBy(id: plantsService.categories[indexPath.row].id)
        cell.imageViewPlant.sd_setImage(with: storageRef)
        cell.titleLabel.text = plantsService.categories[indexPath.row].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // todo do click categorie to next fragment
/*        if let key = key {
            let controller = StoryboardScene.MyPlants.changeNameVC.instantiate()
            controller.plant =  plantTuples[indexPath.row]
            controller.key = key
            controller.gardenerId = gardenerId
            present(controller, animated: true, completion: nil)
        }*/
    }
}
