//
//  ChangeNameVC.swift
//  plantR_ios
//
//  Created by Rabissoni on 21/02/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit
import FirebaseUI

class ChangeNameVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var namePlants: UITextField!
    
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!
    let date = Date()
    
    var plant: (plantName: String, plantInfo: InfosPlants)? = nil
    var key: String?
    var gardenerId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let plant = plant else { return }
        imageView.sd_setImage(with: plant.plantInfo.imagePlant)
        titleLabel.text = plant.plantInfo.infoPlant.name
        descriptionLabel.text = plant.plantInfo.infoPlant.description
    }
    
    @IBAction func infoPlant(_ sender: Any) {
        
        let controller = StoryboardScene.MyPlants.infoPlantVC.instantiate()
        controller.plant = plant
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func addNewPlant(_ sender: Any) {
        guard let infoPlant = plant?.plantInfo.infoPlant else { return }
        
        
        self.choiceSowingOrPlanting(infoPlant: infoPlant)
    }
    
    fileprivate func addPlantSowing(infoPlant: PlantModel) {
        let dateComponent = Calendar.current.dateComponents([.month], from: date)

        guard let currentlyMonth = dateComponent.month, let key = key, let gardenerId = gardenerId, let plant = plant, let name = self.namePlants.text else { return }
        if (checkBetweenStartAndEnd(start: infoPlant.sowingPeriod.startMonth, end: infoPlant.sowingPeriod.endMonth, current: currentlyMonth)) {
            let toAdd = self.gardenerTransformer.toDictionaryToAddPlant(name, plantID: plant.plantName)
            self.gardenerRepository.getPlantsToAdd(by: gardenerId, by: key).setValue(toAdd) { (error, _) in
                self.popOKAlertController(title: NSLocalizedString("the_plant_has_been_added", comment: "the_plant_has_been_added"), message: nil, okHandler: { (_ ) in
                    self.performSegue(withIdentifier: "unwindSegueToPlantsVC", sender: nil)
                })
            }
        } else {
            let nbMonth = nbMonthBeforeStartPeriod(current: currentlyMonth, startPeriod: infoPlant.sowingPeriod.startMonth)
            if (nbMonth == -1) {
                self.popOKAlertController(title: NSLocalizedString("an_error_occurred_while_adding_the_plant,_please_try_again_later", comment: "an_error_occurred_while_adding_the_plant,_please_try_again_later"))
            } else {
                var message = "\(NSLocalizedString("you_will_be_able_to_sow_your", comment: "you_will_be_able_to_sow_your")) \(infoPlant.name) \(NSLocalizedString("in", comment: "IN")) \(nbMonth) \(NSLocalizedString("month", comment: "month")) !"
                self.wishlistPopUp(infoPlant: infoPlant, message: message, sowing: true)
            }
        }
    }
    
    
    fileprivate func addPlantPlanting(infoPlant: PlantModel) {
        let dateComponent = Calendar.current.dateComponents([.month], from: date)
        
        guard let currentlyMonth = dateComponent.month, let key = key, let gardenerId = gardenerId, let plant = plant, let name = self.namePlants.text else { return }

        if (checkBetweenStartAndEnd(start: infoPlant.plantingPeriod.startMonth, end: infoPlant.plantingPeriod.endMonth, current: currentlyMonth)) {
            let toAdd = self.gardenerTransformer.toDictionaryToAddPlant(name, plantID: plant.plantName)
            self.gardenerRepository.getPlantingToAdd(by: gardenerId, by: key).setValue(toAdd) { (error, _) in
                self.popOKAlertController(title: NSLocalizedString("the_plant_has_been_added", comment: "the_plant_has_been_added"), message: nil, okHandler: { (_ ) in
                    self.performSegue(withIdentifier: "unwindSegueToPlantsVC", sender: nil)
                })
            }
        } else {
            var nbMonth = nbMonthBeforeStartPeriod(current: currentlyMonth, startPeriod: infoPlant.plantingPeriod.startMonth)
            if (nbMonth == -1) {
                self.popOKAlertController(title: NSLocalizedString("an_error_occurred_while_adding_the_plant,_please_try_again_later", comment: "an_error_occurred_while_adding_the_plant,_please_try_again_later"))
            } else {
                var message = "\(NSLocalizedString("you_will_be_able_to_sow_your", comment: "you_will_be_able_to_sow_your")) \(infoPlant.name) \(NSLocalizedString("in", comment: "IN")) \(nbMonth) \(NSLocalizedString("month", comment: "month")) !"
                self.wishlistPopUp(infoPlant: infoPlant, message: message, sowing: false)
            }
        }
    }
    
    fileprivate func nbMonthBeforeStartPeriod(current: Int, startPeriod: Int) -> Int{
        var hasEnd = false
        var index = current
        var nb = 0
        var boucleInf = 0
        while(!hasEnd) {
            if (index == startPeriod) {
                hasEnd = true
                break
            } else {
                nb += 1
                index += 1
                if (index >= 13) {
                    index = 0
                    boucleInf += 1
                    if (boucleInf >= 3) {
                        return -1
                    }
                }
            }
        }
        return nb
    }

    
    fileprivate func choiceSowingOrPlanting(infoPlant: PlantModel) {
        let alertController = UIAlertController(title: "\(NSLocalizedString("sow_or_plant_your", comment: "sow_or_plant_your")) \(infoPlant.name) ?", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("sow", comment: "sow"), style: .default, handler: { _ in
            self.addPlantSowing(infoPlant: infoPlant)
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("plant", comment: "plant"), style: .default, handler: { _ in
            self.addPlantPlanting(infoPlant: infoPlant)
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: nil))
        alertController.view.tintColor = Styles.PlantRMainGreen
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func wishlistPopUp(infoPlant: PlantModel, message: String, sowing: Bool) {
        let alertController = UIAlertController(title: NSLocalizedString("please_wait_a_second", comment: "please_wait_a_second"), message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("add_to_my_wishlist", comment: "add_to_my_wishlist"), style: .default, handler: { _ in
            self.gardenerRepository.getWishlistReference(by: self.gardenerId ?? "").observeSingleEvent(of: .value, with: { snapWish in
                var wishModel: [String:WishlistModel] = [:]
                if let snapWish = snapWish.value as? [String: Any] {
                    wishModel = self.gardenerTransformer.toWishlistModel(snapWish)
                }
                if let idPlant = self.plant?.plantName {
                    if (!wishModel.isEmpty) {
                        let exist = wishModel.first(where: { $0.key == idPlant })
                        if exist != nil {
                            self.popOKAlertController(title: NSLocalizedString("the_plant_is_already_in_the_favorites_of_the_gardener", comment: "the_plant_is_already_in_the_favorites_of_the_gardener"))
                        } else {
                            print("* setPlantToWishlist *")
                            self.setPlantToWishlist(idPlant: idPlant, plantModel: infoPlant)
                        }
                    } else {
                        print("* setPlantToWishlist ELSE *")
                        self.setPlantToWishlist(idPlant: self.plant?.plantName ?? "", plantModel: infoPlant)
                    }
                }
            })
        }))
        var textAlreadySowingOrPlanting = sowing == true ? NSLocalizedString("ive_already_seeded", comment: "ive_already_seeded") : NSLocalizedString("ive_already_planted", comment: "ive_already_planted")
        alertController.addAction(UIAlertAction(title: textAlreadySowingOrPlanting, style: .default, handler: { _ in
            print("* ALREADY PLANTED / SOWING *")
            guard let key = self.key, let plantId = self.plant?.plantName else {
                print("* EXIT GUARD *")
                return
            }
            let controller = StoryboardScene.MyPlants.selectDateAlreadyPlantVC.instantiate()
            controller.plant = self.plant
            controller.location = key
            controller.plantID = plantId
            controller.gardenerId = self.gardenerId
            controller.sowing = sowing
            
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .overFullScreen
            
            self.present(controller, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: nil))
        alertController.view.tintColor = Styles.PlantRMainGreen
        self.present(alertController, animated: true, completion: nil)
    }

    private func setPlantToWishlist(idPlant: String, plantModel: PlantModel) {
        var arrayInfo = WishlistModel(plantId: idPlant, sowingPeriod: plantModel.sowingPeriod, plantingPeriod: plantModel.plantingPeriod)
        print(arrayInfo)
        var wishlistModel = self.gardenerTransformer.toDictonaryWishlistModel(arrayInfo)
        print(wishlistModel)
        print("* END WISHLIST *")
        self.gardenerRepository.getWishlistReference(by: gardenerId ?? "").child(idPlant).setValue(wishlistModel, withCompletionBlock: { error, dataRef in
            if error == nil {
                self.popOKAlertController(title: NSLocalizedString("the_plant_has_been_added_in_the_wishlist", comment: "the_plant_has_been_added_in_the_wishlist"), message: "", okHandler: {_ in
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                })
            } else {
                self.popOKAlertController(title: NSLocalizedString("an_error_occurred_while_adding_to_the_wishlist", comment: "an_error_occurred_while_adding_to_the_wishlist"))
            }
        })
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
