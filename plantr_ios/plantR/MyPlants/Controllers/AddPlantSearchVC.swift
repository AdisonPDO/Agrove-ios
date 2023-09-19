//
//  AddPlantSearchVC.swift
//  plantR_ios
//
//  Created by Rabissoni on 19/02/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class AddPlantSearchVC: UIViewController {

    @IBOutlet var lTitleStage: UILabel!
    @IBOutlet weak var numberFloor: UILabel!
    @IBOutlet weak var stageNumberLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var levelOccupationImageView: [UIImageView]!
    @IBOutlet var svOccupation: UIStackView!
    @IBOutlet var ivHeaderGardener: UIImageView!
    
    var plantsService: PlantsService!

    private var plantsSuggest: [String] = []

    var gardenerId: String?
    var key: String?
    var allPlants: [String: GardenerPlantModel] = [:]
    var gardener: GardenerModel?

    private var plantRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lTitleStage.adjustsFontSizeToFitWidth = true
        self.lTitleStage.minimumScaleFactor = 0.2
        
        let date = Date()
        let dateComponent = Calendar.current.dateComponents([.month], from: date)
        guard let currentlyMonth = dateComponent.month, let key = key, let gardener = gardener else { return }
    
        self.setupHeaderView(stage: key.first!, gardener)

        let arrayKey = Array(self.plantsService.plants.keys).sorted()
        
        let sorted = arrayKey.filter({
            $0 == "parsley" || $0 == "coriander" || $0 == "basil" || $0 == "bittermelon" || $0 == "cherrytomato" || $0 == "radish" || $0 == "spinach" || $0 == "onion" || $0 == "welshonion"
        })
        let unsorted = arrayKey.filter({
            $0 != "parsley" && $0 != "coriander" && $0 != "basil" && $0 != "bittermelon" && $0 != "cherrytomato" && $0 != "radish" && $0 != "spinach" && $0 != "onion" && $0 != "welshonion"
        })
        let finalArray =  NSLocale.current.languageCode! == "en" ? sorted : unsorted
        
        for plantId in finalArray {
            let plant = self.plantsService.plants[plantId]!
            let startSowing = plant.infoPlant.sowingPeriod.startMonth
            let endSowing = plant.infoPlant.sowingPeriod.endMonth
            let startPlanting = plant.infoPlant.plantingPeriod.startMonth
            let endPlanting = plant.infoPlant.plantingPeriod.endMonth
            let name = plant.infoPlant.name.lowercased()

            if checkBetweenStartAndEnd(start: startSowing, end: endSowing, current: currentlyMonth) {
                self.plantsSuggest.append(plantId)
            } else {
                if (checkBetweenStartAndEnd(start: startPlanting, end: endPlanting, current: currentlyMonth)) {
                    self.plantsSuggest.append(plantId)
                }
            }
        }
        self.collectionView.reloadData()
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    func setupHeaderView(stage: Character,_ gardener: GardenerModel) {
        self.setLevelOccupation(stage: stage, gardener)
        switch gardener.type {
        case "cle_en_main":
            self.lTitleStage.text = NSLocalizedString("level", comment: "level")
            setFormatKeyForStage(stage: stage, gardener, label: self.stageNumberLabel)
        case "carre","capteur_carre":
            self.lTitleStage.text = NSLocalizedString("row", comment: "row")
            setFormatKeyForStage(stage: stage, gardener, label: self.stageNumberLabel)
        case "parcelle":
            let maxStage = (Int(gardener.stage) ?? 4) - 1
            let currentStage = (Int(String(stage)) ?? 0)
            if ((0...maxStage).contains(currentStage)) {
                self.lTitleStage.text = NSLocalizedString("level", comment: "level")
                setFormatKeyForStage(stage: stage, gardener, label: self.stageNumberLabel)
            } else {
                self.lTitleStage.text = NSLocalizedString("row", comment: "row")
                setFormatKeyForRangInParcelle(rang: (maxStage + gardener.rangs) - currentStage, gardener, label: self.stageNumberLabel)
            }
        default:
            self.lTitleStage.text = gardener.metadata.name
            self.lTitleStage.font = lTitleStage.font.withSize(20)
            self.stageNumberLabel.text = " "
        }
        setImageGenericGardenerGreen(gardener: gardener, ivCenter: self.ivHeaderGardener)
    }

    func setLevelOccupation(stage: Character,_ gardener: GardenerModel) {

        switch gardener.type {
        case "cle_en_main", "mural", "parcelle":
            print("CLE EN MAIN / MURAL ->")
            self.setOccupationView(maxRow: GardenerConsts.NumbersOfPlantsInStage, stage)
        case "pot", "capteur_pot", "jardiniere", "capteur_jardiniere":
            print("POT ->")
            self.svOccupation.isHidden = true
        case "carre":
            print("CARRE ->")
            switch gardener.dimension {
            case 0:
                self.setOccupationView(maxRow: DimensionType.Carre0, stage)
            case 1:
                self.setOccupationView(maxRow: DimensionType.Carre1, stage)
            case 2:
                self.setOccupationView(maxRow: DimensionType.Carre2, stage)
            default:
                self.setOccupationView(maxRow: DimensionType.Carre2, stage)
            }
        case "capteur_carre":
            print("CARRE ->")
            switch gardener.dimension {
            case 0:
                self.setOccupationView(maxRow: DimensionType.Carre0, stage)
            case 1:
                self.setOccupationView(maxRow: DimensionType.Carre1, stage)
            case 2:
                self.setOccupationView(maxRow: DimensionType.Carre2, stage)
            default:
                self.setOccupationView(maxRow: DimensionType.Carre2, stage)
            }
        case "jardiniere":
            print("JARDINIERE ->")
            switch gardener.dimension {
            case 0:
                self.setOccupationView(maxRow: DimensionType.Jardiniere0, stage)
            case 1:
                self.setOccupationView(maxRow: DimensionType.Jardiniere1, stage)
            case 2:
                self.setOccupationView(maxRow: DimensionType.Jardiniere2, stage)
            default:
                self.setOccupationView(maxRow: DimensionType.Jardiniere2, stage)
            }
        default:
            print("DEFAULT ->")
            self.setOccupationView(maxRow: GardenerConsts.NumbersOfPlantsInStage, stage)
        }
        
    }
    fileprivate func setOccupationView(maxRow: Int,_ stage: Character) {
        for row in 0..<maxRow {
            self.levelOccupationImageView[row].isHighlighted = allPlants["\(stage)-\(row)"] != nil
            self.levelOccupationImageView[row].isHidden = false
        }
    }
    
    @IBAction func goToAddPlantVCButton(_ sender: Any) {
        let controller = StoryboardScene.MyPlants.addPlantsVC.instantiate()
        controller.key = key
        controller.gardenerId = gardenerId
        present(controller, animated: true, completion: nil)
    }
}

extension AddPlantSearchVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.plantsSuggest.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let month = formatter.string(from: date)
        
        let dateComponent = Calendar.current.dateComponents([.month], from: date)

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestionCell", for: indexPath) as! RecommendationCVC
        let keyPlantName = self.plantsSuggest[indexPath.row]
        let plantUID = keyPlantName
        cell.delegate = self
        cell.plantUID = plantUID
        cell.dictPlant = self.plantsService.plants[plantUID]
        let plant =  self.plantsService.plants[plantUID]
        if let plantModel = plant, let currentlyMonth = dateComponent.month {
            cell.titleLabel.text = plantModel.infoPlant.name
            cell.descriptionLabel.text = plantModel.infoPlant.description
            cell.seasonLabel.text = displaySuggest(currentlyMonth: currentlyMonth, plantModel: plantModel)
            cell.imageViewPlant.sd_setImage(with: plantModel.imagePlant)
        }
        return cell
    }
    
    func displaySuggest(currentlyMonth: Int, plantModel: InfosPlants) -> String {
        var sowingText = ""
        var plantingText = ""
        var finalText = ""
        
        if (checkBetweenStartAndEnd(start: plantModel.infoPlant.sowingPeriod.startMonth, end: plantModel.infoPlant.sowingPeriod.endMonth, current: currentlyMonth)) {
            sowingText = NSLocalizedString("to_sow", comment: "to sow")
        }
        if (checkBetweenStartAndEnd(start: plantModel.infoPlant.plantingPeriod.startMonth, end: plantModel.infoPlant.plantingPeriod.endMonth, current: currentlyMonth)) {
            plantingText = NSLocalizedString("to_plant", comment: "to plant")
        }
        if (!sowingText.isEmpty && !plantingText.isEmpty) {
            finalText = sowingText + " \(NSLocalizedString("or", comment: "or")) " + plantingText
        } else {
            if (sowingText.isEmpty) {
                finalText = plantingText
            } else {
                finalText = sowingText
            }
        }
        return finalText
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! RecommendationCVC
        
        guard let infoPlant = cell.dictPlant, let plantUID = cell.plantUID else { return }
        let plantInit = (plantName: plantUID, plantInfo: infoPlant)
        let controller = StoryboardScene.MyPlants.changeNameVC.instantiate()
        controller.key = key
        controller.gardenerId = gardenerId
        controller.plant = plantInit
        present(controller, animated: true, completion: nil)
    }
}

extension AddPlantSearchVC: RecommendationCVCDelegate {
    
    func didSelectInfoPlantButton(keyPlant: InfosPlants) {

        let controller = StoryboardScene.MyPlants.infoPlantVC.instantiate()
        let tuple = (plantName: "", plantInfo: keyPlant)
        controller.plant = tuple
        present(controller, animated: true, completion: nil)
    }
}
