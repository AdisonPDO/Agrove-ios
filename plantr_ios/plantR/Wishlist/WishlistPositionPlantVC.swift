//
//  WishlistPositionPlantVC.swift
//  plantR_ios
//
//  Created by Boris Roussel on 05/03/2021.
//  Copyright © 2021 Agrove. All rights reserved.
//

import UIKit

class WishlistPositionPlantVC: UIViewController, WishlistStageCellDelegate {
    func didSelectButtonAt(key: String) {
        print("key => \(key)")
        print("SelectedArray => \(selectedStage)")
        if (self.selectedStage.contains(key)) {
            if let index = selectedStage.firstIndex(of: key) {
                selectedStage.remove(at: index)
            }
        } else {
            self.selectedStage.append(key)
        }
        self.wishlistStageTVC.reloadData()
    }
    
    @IBOutlet weak var wishlistStageTVC: UITableView!
    @IBOutlet weak var tvTitle: UILabel!
    
    var plantsService: PlantsService!
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!
    
    var currentGardenerStage = 0
    var wishlistToAdd: WishlistModelToAdd?
    var gardenerId: String?
    var gardenerModel: GardenerModel?
    
    private var allPlants: [String: GardenerPlantModel] = [:]
    private var selectedStage: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let wishlistToAdd = wishlistToAdd {
            switch wishlistToAdd.type {
            case "planter":
                self.tvTitle.text = "\(NSLocalizedString("where_do_you_want_to_plant_your", comment: "Where do you want to plant your")) \(wishlistToAdd.plantName)"
                self.tvTitle.isHidden = false
            case "semer":
                self.tvTitle.text = "\(NSLocalizedString("where_do_you_want_to_sow_your", comment: "Where do you want to sow your")) \(wishlistToAdd.plantName)"
                self.tvTitle.isHidden = false
            default:
                break
            }
        }
        
        if let gardenerId = gardenerId {
            self.gardenerRepository.getReference(for: gardenerId).observeSingleEvent(of: .value, with: { snapGardener in
                self.gardenerModel = self.gardenerTransformer.toGardenerModel(snap: snapGardener)
                if (self.gardenerModel?.stage.isEmpty == false) {
                    if let stage = self.gardenerModel?.stage {
                        self.currentGardenerStage = Int(stage) ?? 4
                    } else {
                        self.currentGardenerStage = 4
                    }
                } else {
                    self.currentGardenerStage = 4
                }
                self.gardenerRepository.getAllPlantsReference(by: gardenerId).observeSingleEvent(of: .value, with: { (snapPlants) in
                    let plants = snapPlants.value as? [String: Any] ?? [:]
                    let plantsFormated = plants.mapValues { self.gardenerTransformer.toGardenerPlantModel($0 as! [String: Any]) }
                    
                    self.allPlants = plantsFormated
                    self.wishlistStageTVC.reloadData()
                })
            })
        }
        
        
    }
    @IBAction func backTapped(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addToGardener(_ sender: UIButton) {
        print("* addToGardener *")
        print("\(selectedStage.count)")
        if selectedStage.count > 0 {
            if let wishlistToAdd = wishlistToAdd, let gardenerId = gardenerId {
                switch wishlistToAdd.type {
                case "planter":
                    let toAdd = self.gardenerTransformer.toDictionaryToAddPlant(wishlistToAdd.plantName, plantID: wishlistToAdd.plantId)
                    selectedStage.forEach({
                        self.gardenerRepository.getPlantingToAdd(by: gardenerId, by: $0).setValue(toAdd)
                    })
                    self.gardenerRepository.getWishlistReference(by: gardenerId).child(wishlistToAdd.plantId).removeValue()
                    if (self.selectedStage.count > 1) {
                        self.popOKAlertController(title: NSLocalizedString("your_plants_were_well_added", comment: "Your plants were well added"), message: "", okHandler: {_ in
                            self.performSegue(withIdentifier: "unwindSegueToPlantsVC", sender: nil)
                        })
                    } else {
                        self.popOKAlertController(title: NSLocalizedString("your_plants_were_well_added", comment: "Your plant were well added"), message: "", okHandler: {_ in
                            self.performSegue(withIdentifier: "unwindSegueToPlantsVC", sender: nil)
                        })
                    }
                case "semer":
                    let toAdd = self.gardenerTransformer.toDictionaryToAddPlant(wishlistToAdd.plantName, plantID: wishlistToAdd.plantId)
                    selectedStage.forEach({
                        self.gardenerRepository.getPlantsToAdd(by: gardenerId, by: $0).setValue(toAdd)
                    })
                    self.gardenerRepository.getWishlistReference(by: gardenerId).child(wishlistToAdd.plantId).removeValue()
                    if (self.selectedStage.count > 1) {
                        self.popOKAlertController(title: NSLocalizedString("your_plants_were_well_added", comment: "Your plants were well added"), message: "", okHandler: {_ in
                            self.performSegue(withIdentifier: "unwindSegueToPlantsVC", sender: nil)
                        })
                    } else {
                        self.popOKAlertController(title: NSLocalizedString("your_plant_were_well_added", comment: "Your plant were well added"), message: "", okHandler: {_ in
                            self.performSegue(withIdentifier: "unwindSegueToPlantsVC", sender: nil)
                        })
                    }
                default:
                    break
                }
            }
        } else {
            self.popOKAlertController(title: NSLocalizedString("you_must_select_at_least_one_location", comment: "You must select at least one location"))
        }
    }
    
    fileprivate func checkPlantExisting(stage:Int, row: Int, ivImage: CIRoundedImageView) {
        if let plant = self.allPlants["\(stage)-\(row)"], let image = plantsService.plants[plant.plantID]?.imagePlant  {
            ivImage.sd_setImage(with: image)
        } else {
            if self.selectedStage.contains("\(stage)-\(row)") {
                ivImage.image = UIImage(named: "cercleFill")
            } else {
                ivImage.image = UIImage(named: "cercleEmpty")
            }
        }
    }
}

extension WishlistPositionPlantVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let gardenerModel = self.gardenerModel {
            if (gardenerModel.type == "parcelle") {
                return currentGardenerStage + (gardenerModel.rangs ?? 0)
            } else {
                return currentGardenerStage
            }
        }
        return currentGardenerStage
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wishlistStage", for: indexPath) as! WishlistStageCell
        if let gardenerModel = gardenerModel {
            //            let stageNumber = String(currentGardenerStage - indexPath.row)
            let stageNumber = (self.currentGardenerStage + gardenerModel.rangs) - indexPath.row
            cell.delegate = self
            //            cell.stageIv.image = UIImage(named: "etage\(currentGardenerStage)\(stageNumber)")
            
            switch gardenerModel.type {
            case "cle_en_main":
                cell.stageIv.image = UIImage(named: "etage\(self.currentGardenerStage)\(stageNumber)")
            case "carre":
                cell.stageIv.image = UIImage(named: "rang\(self.currentGardenerStage)-\(stageNumber)")
            case "capteur_carre":
                cell.stageIv.image = UIImage(named: "rang\(self.currentGardenerStage)-\(stageNumber)")
            case "pot":
                cell.stageIv.image = UIImage(named: "mes_plantes_pot_gris")
            case "capteur_pot":
                cell.stageIv.image = UIImage(named: "capteur_pot_gris")
            case "jardiniere":
                cell.stageIv.image = UIImage(named: "jardiniere_gris")
            case "capteur_jardiniere":
                cell.stageIv.image = UIImage(named: "capteur_jardiniere_gris")
            case "parcelle":
                if (stageNumber <= gardenerModel.rangs) {
                    switch stageNumber {
                    case 2:
                        cell.stageIv.image = UIImage(named: "rang2-1")
                    case 1:
                        cell.stageIv.image = UIImage(named: "rang2-2")
                    default:
                        cell.stageIv.image = UIImage(named: "rang2-1")
                    }
                } else {
                    cell.stageIv.image = UIImage(named: "etage\(self.currentGardenerStage)\(stageNumber - gardenerModel.rangs)")
                }
            default:
                print("No Value Here")
            }
            cell.stage = indexPath.row
            
            let numberOfRow = setNumberOfRowOfType(gardenerModel)
            print("Number of row => \(numberOfRow)")
            switch numberOfRow {
            case 1:
                checkPlantExisting(stage: indexPath.row, row: 0, ivImage: cell.plantOneIV)
                cell.plantTwoIV.isHidden = true
                cell.plantThreeIV.isHidden = true
                cell.plantFourIV.isHidden = true
                cell.vTwo.isHidden = true
                cell.vThree.isHidden = true
                cell.vFour.isHidden = true
            case 2:
                checkPlantExisting(stage: indexPath.row, row: 0, ivImage: cell.plantOneIV)
                checkPlantExisting(stage: indexPath.row, row: 1, ivImage: cell.plantTwoIV)
                cell.plantThreeIV.isHidden = true
                cell.plantFourIV.isHidden = true
                cell.vThree.isHidden = true
                cell.vFour.isHidden = true
            case 3:
                checkPlantExisting(stage: indexPath.row, row: 0, ivImage: cell.plantOneIV)
                checkPlantExisting(stage: indexPath.row, row: 1, ivImage: cell.plantTwoIV)
                checkPlantExisting(stage: indexPath.row, row: 2, ivImage:cell.plantThreeIV)
                cell.plantFourIV.isHidden = true
                cell.vFour.isHidden = true
            case 4:
                checkPlantExisting(stage: indexPath.row, row: 0, ivImage: cell.plantOneIV)
                checkPlantExisting(stage: indexPath.row, row: 1, ivImage: cell.plantTwoIV)
                checkPlantExisting(stage: indexPath.row, row: 2, ivImage:cell.plantThreeIV)
                checkPlantExisting(stage: indexPath.row, row: 3, ivImage: cell.plantFourIV)
            default:
                checkPlantExisting(stage: indexPath.row, row: 0, ivImage: cell.plantOneIV)
                checkPlantExisting(stage: indexPath.row, row: 1, ivImage: cell.plantTwoIV)
                checkPlantExisting(stage: indexPath.row, row: 2, ivImage:cell.plantThreeIV)
                checkPlantExisting(stage: indexPath.row, row: 3, ivImage: cell.plantFourIV)
            }
            
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
        }
        
        return cell
    }
}
