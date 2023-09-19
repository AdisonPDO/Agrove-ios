//
//  addPlantsVC.swift
//  plantR_ios
//
//  Created by Rabissoni on 15/02/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class GPPresPickerData {
    
    init(title: String, data: [String], selectedData: String) {
        self.title = title
        self.data = data
        self.selectedData = selectedData
    }
    
    var title: String!
    var data: [String]!
    var selectedData: String!
}

class AddPlantsVC: UIViewController, DataPickerTextFieldDelegate {
    
    func didSelectRow(pickerView: UIPickerView, row: Int, component: Int, identifier: String, value: String) {
        var selectedCategory = plantsService.categories.filter({ $0.name == (NSLocale.current.languageCode! == "en" ? categoryUtils.enToFr(str: value) : value) })
        if selectedCategory != nil {
            categorie = selectedCategory.first
        } else {
            categorie = nil
        }
        var text = self.searchLabel.text ?? ""
        print(text.isEmpty)
        if (!text.isEmpty) {
            if categorie != nil {
                plantTuples = allPlantTuples.filter({ $0.plantInfo.infoPlant.name.lowercased().prefix(text.count) == text.lowercased() }).filter({ $0.plantInfo.infoPlant.filter.contains(categorie?.id.capitalized ?? "")})
            } else {
                plantTuples = allPlantTuples.filter({ $0.plantInfo.infoPlant.name.lowercased().prefix(text.count) == text.lowercased() })
            }
        } else {
            if categorie != nil {
                plantTuples = allPlantTuples.filter({ $0.plantInfo.infoPlant.filter.contains(categorie?.id.capitalized ?? "")})
            } else {
                plantTuples = allPlantTuples
            }
        }
        self.collectionView.reloadData()
    }
    

    @IBOutlet weak var searchLabel: UITextField!
    @IBOutlet weak var notPlant: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var tfCategory: DataPickerTextField!
    var key: String?
    var gardenerId: String?
    var categorie: CategoryModel?
    var categoryUtils = UtilsCategories()
    
    private var allPlantTuples: [(plantName: String, plantInfo: InfosPlants)] = []
    private var plantTuples: [(plantName: String, plantInfo: InfosPlants)] = []
    var plantsService: PlantsService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var arrayData = [NSLocalizedString("all_plants", comment: "all_plants")]
        
        self.tfCategory.pickerViewDelegate = self
        plantsService.categories.forEach({ if NSLocale.current.languageCode! == "en" {
            arrayData.append(categoryUtils.frToEn(str: $0.name))
        }else{
            arrayData.append($0.name)
        } })

        tfCategory.dataValues = arrayData
        
        let or =  plantsService.plants.filter({$0.key != "parsley" && $0.key != "coriander" && $0.key != "basil" && $0.key != "bittermelon" && $0.key != "cherrytomato" && $0.key != "radish" && $0.key != "spinach" && $0.key != "onion" && $0.key != "welshonion"}).sorted(by: { $0.key < $1.key }).map({
            return (plantName: $0.key, plantInfo: $0.value)
        })
        
        let en = plantsService.plants.filter({$0.key == "parsley" || $0.key == "coriander" || $0.key == "basil" || $0.key == "bittermelon" || $0.key == "cherrytomato" || $0.key == "radish" || $0.key == "spinach" || $0.key == "onion" || $0.key == "welshonion"}).sorted(by: { $0.key < $1.key }).map({
            return (plantName: $0.key, plantInfo: $0.value)
        })
        
        //TODO: TO RESOLVE => Les fruits & legumes en anglais sont anormalement present dans le tableau en fr
        allPlantTuples =  NSLocale.current.languageCode! == "en" ? en : or
        
        if let categorie = categorie {
            plantTuples = allPlantTuples.filter({ $0.plantInfo.infoPlant.filter.contains(categorie.id.capitalized)})
            collectionView.reloadData()
        } else {
            plantTuples = allPlantTuples
            collectionView.reloadData()
        }
    }
    
    @IBAction func filterPlantModel(_ sender: UITextField) {
        guard let text = sender.text, !text.isEmpty else {
            if let categorie = categorie {
                plantTuples = allPlantTuples.filter({ $0.plantInfo.infoPlant.filter.contains(categorie.id.capitalized)})
                collectionView.reloadData()
            } else {
                plantTuples = allPlantTuples
                collectionView.reloadData()
            }
            return
        }
        
        if let categorie = categorie {
            plantTuples = allPlantTuples.filter({ $0.plantInfo.infoPlant.name.lowercased().prefix(text.count) == text.lowercased() }).filter({ $0.plantInfo.infoPlant.filter.contains(categorie.id.capitalized)})
        } else {
            plantTuples = allPlantTuples.filter({ $0.plantInfo.infoPlant.name.lowercased().prefix(text.count) == text.lowercased() })
        }
       
        collectionView.reloadData()
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}

extension AddPlantsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plantTuples.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = (collectionView.bounds.width / 2) - 18
        return CGSize(width: screenWidth, height: screenWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantsCell", for: indexPath) as! AddPlantCVC
        let plantPath = plantTuples[indexPath.row]
        cell.imageViewPlant.sd_setImage(with: plantPath.plantInfo.imagePlant)
        cell.titleLabel.text = plantPath.plantInfo.infoPlant.name
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
        if let key = key {
            let controller = StoryboardScene.MyPlants.changeNameVC.instantiate()
            controller.plant =  plantTuples[indexPath.row]
            controller.key = key
            controller.gardenerId = gardenerId
            present(controller, animated: true, completion: nil)
        }
    }
}
