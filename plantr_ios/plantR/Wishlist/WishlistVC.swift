//
//  WishlistVC.swift
//  plantR_ios
//
//  Created by Boris Roussel on 21/12/2020.
//  Copyright © 2020 Agrove. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import Foundation

struct WishlistModelToAdd {
    var type: String
    var plantName: String
    var plantId: String
}

class WishlistVC: UIViewController {
    
    @IBOutlet weak var notPlant: UILabel!
    @IBOutlet weak var tvAwailable: UILabel!
    @IBOutlet weak var cvAwailable: UICollectionView!
    @IBOutlet weak var tvNotAwailable: UILabel!
    @IBOutlet weak var cvNotAwailable: UICollectionView!
    @IBOutlet weak var svAwailable: UIStackView!
    @IBOutlet weak var svNotAwailable: UIStackView!
    @IBOutlet var dsNotAwailable: WishlistNotAwailableDataSource!
    
    @IBOutlet weak var vBody: UIView!
    @IBOutlet weak var vEmptyBody: UIView!
    
    @IBOutlet weak var ibBack: UIButton!
    
    let wishlistNotAwailableViewModel = WishlistNotAwailableViewModel()
    
    private var plantTuplesAwailable: [(plantName: String, plantInfo: InfosPlants, dateOk: WishlistModel)] = []
    private var plantTuplesNotAwailable: [(plantName: String, plantInfo: InfosPlants, dateOk: WishlistModel)] = []
    
    var plantsService: PlantsService!
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!
    
    private var handleAddWishlist: UInt?
    private var wishlistReference: DatabaseReference?

    //    var key: String?
    var gardenerId: String?
    var wishlistToAdd: WishlistModelToAdd?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            ibBack.setImage(UIImage(named: "croixVertDashboard"), for: .normal)
        } else {
            ibBack.setImage(UIImage(named: "flecheRetourVert"), for: .normal)
        }
        
        self.dsNotAwailable.wishlistNotAwailableViewModel = self.wishlistNotAwailableViewModel
        
        
        self.wishlistReference = self.gardenerRepository.getWishlistReference(by: self.gardenerId ?? "")
        self.handleAddWishlist = self.wishlistReference?.observe(.value, with: { [self] snap in
            plantTuplesAwailable = []
            guard let snapDict = snap.value as? [String: Any] else {
                self.vEmptyBody.isHidden = false
                return
            }
            let wishlistModel = self.gardenerTransformer.toWishlistModel(snapDict)
            wishlistModel.forEach({ wish in
                let date = Date()
                let dateComponent = Calendar.current.dateComponents([.month], from: date)
                
                let currentlyMonth = dateComponent.month != nil ? dateComponent.month : -1
                
                if (currentlyMonth != -1) {
                    let sowingState = checkBetweenStartAndEnd(start: wish.value.sowingPeriod.startMonth, end: wish.value.sowingPeriod.endMonth, current: currentlyMonth!)
                    let plantingState = checkBetweenStartAndEnd(start: wish.value.plantingPeriod.startMonth, end: wish.value.plantingPeriod.endMonth, current: currentlyMonth!)
                    if let plant = plantsService.plants.first(where: {$0.key == wish.key}) {
                        if (sowingState || plantingState) {
                            plantTuplesAwailable.append((plantName: plant.value.infoPlant.name, plantInfo: plant.value, dateOk: wish.value))
                        } else {
                            self.wishlistNotAwailableViewModel.plantNotAwailable.append((plantName: plant.value.infoPlant.name, plantInfo: plant.value, dateOk: wish.value))
                        }
                    }
                }
            })
            if (wishlistNotAwailableViewModel.plantNotAwailable.count == 0 && plantTuplesAwailable.count == 0) {
                self.vBody.isHidden = true
                self.vEmptyBody.isHidden = false
            } else {
                self.vBody.isHidden = false
                self.vEmptyBody.isHidden = true
                if (wishlistNotAwailableViewModel.plantNotAwailable.count == 0) {
                    self.svNotAwailable.isHidden = true
                } else {
                    self.svNotAwailable.isHidden = false
                }
                if (plantTuplesAwailable.count == 0) {
                    self.svAwailable.isHidden = true
                } else {
                    self.svAwailable.isHidden = false
                }
            }
            DispatchQueue.main.async {
                print("* VALUE \(self.wishlistNotAwailableViewModel.plantNotAwailable.count)")
                self.cvNotAwailable.reloadData()
            }
            self.cvAwailable.reloadData()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let handleAddWishlist = handleAddWishlist {
            self.wishlistReference?.removeObserver(withHandle: handleAddWishlist)
        }
    }
    @IBAction func backTapped(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    private func goToPositionPlants(state: WishlistState) {
        /*                    let controller = StoryboardScene.MyPlants.changeNameVC.instantiate()
         controller.plant =  plantTuples[indexPath.row]
         controller.gardenerId = gardenerId
         present(controller, animated: true, completion: nil)*/
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? WishlistPositionPlantVC {
                destination.wishlistToAdd = wishlistToAdd
                destination.gardenerId = gardenerId
        }
    }
}

extension WishlistVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plantTuplesAwailable.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantsCell", for: indexPath) as! AddPlantCVC
        let plantPath = plantTuplesAwailable[indexPath.row]
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
            cell.stateInfoLabel.text = NSLocalizedString("plant", comment: "plant your plant")
        } else if (sowingState && plantingState) {
            cell.state = .twice
            cell.stateInfoLabel.text = NSLocalizedString("sow_or_plant", comment: "sow or plant")
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
        let plant = plantTuplesAwailable[indexPath.row]
        switch cell.state {
        case .planting:
            print("PLANTING")
            self.wishlistToAdd = WishlistModelToAdd(type: "planter", plantName: plant.plantInfo.infoPlant.name, plantId: plant.dateOk.plantId)
            self.performSegue(withIdentifier: "wishlistToAdd", sender: wishlistToAdd)
        case .sowing:
            print("SOWING")
            self.wishlistToAdd = WishlistModelToAdd(type: "semer", plantName: plant.plantInfo.infoPlant.name, plantId: plant.dateOk.plantId)
            self.performSegue(withIdentifier: "wishlistToAdd", sender: wishlistToAdd)
        case .twice:
            print("TWICE")
            let alertController = UIAlertController(title: "\(NSLocalizedString("sow_or_plant_your", comment: "sow or plant your plant"))  \(plant.plantInfo.infoPlant.name) ?", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("sow", comment: "sow your plant"), style: .default, handler: { _ in
                self.wishlistToAdd = WishlistModelToAdd(type: "semer", plantName: plant.plantInfo.infoPlant.name, plantId: plant.dateOk.plantId)
                self.performSegue(withIdentifier: "wishlistToAdd", sender: self.wishlistToAdd)
            }))
            alertController.addAction(UIAlertAction(title: NSLocalizedString("plant", comment: "plant or plant"), style: .default, handler: { _ in
                self.wishlistToAdd = WishlistModelToAdd(type: "planter", plantName: plant.plantInfo.infoPlant.name, plantId: plant.dateOk.plantId)
                self.performSegue(withIdentifier: "wishlistToAdd", sender: self.wishlistToAdd)
            }))
            alertController.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel action"), style: .cancel, handler: nil))
            alertController.view.tintColor = Styles.PlantRMainGreen
            self.present(alertController, animated: true, completion: nil)
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
