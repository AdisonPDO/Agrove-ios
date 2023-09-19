//
//  PlantsVC.swift
//  plantR_ios
//
//  Created by Rabissoni on 06/02/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class PlantsVC: UIViewController {

    var userRepository: UserRepository!
    var userTransformer: UserTransformer!
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!
    var plantsService: PlantsService!
    @IBOutlet weak var vAlertWishlist: CIRoundedImageView!
    
    private var currentUser: User!
    private var currentGardener: String?
    private var currentGardenerStage: Int = 4
    private var currentGardenerModel: GardenerModel? = nil

    private var currentGardenerRef: DatabaseReference!
    private var allPlantsGardenerRef: DatabaseReference!
    private var wishlistRef: DatabaseReference!

    private var handleCurrentGardener: UInt?
    private var handleGardener: UInt?
    private var handleWishlist: UInt?
    
    private var allPlants: [String: GardenerPlantModel] = [:]
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentUser = Auth.auth().currentUser
        self.currentGardenerRef = self.userRepository.getCurrentGardenerReference(for: currentUser.uid)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        navigationController?.navigationBar.barStyle = UIBarStyle.black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.handleCurrentGardener = self.currentGardenerRef.observe(.value, with: {(snapCurrentGardener) in
            let currentGardener = snapCurrentGardener.value as! String
            self.currentGardener = currentGardener
            self.wishlistRef = self.gardenerRepository.getWishlistReference(by: currentGardener)
            self.handleWishlist = self.wishlistRef.observe(.value, with: { snapWish in
                if (snapWish.exists()) {
                    var alert = false
                    let date = Date()
                    let dateComponent = Calendar.current.dateComponents([.month], from: date)
                    
                    guard let currentlyMonth = dateComponent.month, let wishlist = snapWish.value as? [String: Any] else { return }
                    let wishModel = self.gardenerTransformer.toWishlistModel(wishlist)
                    wishModel.forEach({
                        if (checkBetweenStartAndEnd(start: $0.value.plantingPeriod.startMonth, end: $0.value.plantingPeriod.endMonth, current: currentlyMonth)) {
                            alert = true
                            return
                        }
                        if (checkBetweenStartAndEnd(start: $0.value.sowingPeriod.startMonth, end: $0.value.sowingPeriod.endMonth, current: currentlyMonth)) {
                            alert = true
                            return
                        }
                    })
                    if (alert) {
                        self.vAlertWishlist.isHidden = false
                    } else {
                        self.vAlertWishlist.isHidden = true
                    }
                } else {
                    self.vAlertWishlist.isHidden = true
                }
            })
            self.gardenerRepository.getReference(for: currentGardener).observeSingleEvent(of: .value, with: { snapShot in
                self.currentGardenerModel = self.gardenerTransformer.toGardenerModel(snap: snapShot)
               
                self.currentGardenerStage = Int(self.currentGardenerModel!.stage) ?? 4
                self.allPlantsGardenerRef = self.gardenerRepository.getAllPlantsReference(by: currentGardener)
                self.handleGardener = self.allPlantsGardenerRef.observe(.value, with: { (snapPlants) in
                    let plants = snapPlants.value as? [String: Any] ?? [:]
                    let plantsFormated = plants.mapValues { self.gardenerTransformer.toGardenerPlantModel($0 as! [String: Any]) }
                    self.allPlants = plantsFormated
                    self.tableView.reloadData()
                })
            })
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let handleCurrentGardener = handleCurrentGardener {
            self.currentGardenerRef.removeObserver(withHandle: handleCurrentGardener)
        }
        if let handleGardener = handleGardener {
            self.allPlantsGardenerRef.removeObserver(withHandle: handleGardener)
        }
        if let handleWishlist = handleWishlist {
            self.wishlistRef.removeObserver(withHandle: handleWishlist)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  "goToInfoDescriptionPlantVC" {
            let key = sender as! String
            let controller = segue.destination as! InfoPlantMyPlantsVC
                    controller.plant = allPlants[key]!
                    controller.gardenerId = currentGardener
                    controller.key = key
        }
        if let destination = segue.destination as? WishlistVC {
            destination.gardenerId = self.currentGardener
        }
    }
    
    @IBAction func wishlistTapped(_ sender: UIButton) {
        let controller = StoryboardScene.Wishlist.wishlistVC.instantiate()
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        controller.gardenerId = self.currentGardener
        self.present(controller, animated: true, completion: nil)
//        self.performSegue(withIdentifier: "goToWishlist", sender: nil)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func unwindToPlantsVC(_ sender: UIStoryboardSegue) {}
    
}

extension PlantsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentGardenerStage + (self.currentGardenerModel?.rangs ?? 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gardenerFloorCell", for: indexPath) as! GardenerFloorTCell
        cell.collectionView.showsHorizontalScrollIndicator = true
        guard let currentGardener = currentGardenerModel else { return cell }
        let stageNumber = (self.currentGardenerStage + currentGardener.rangs) - indexPath.row
        cell.delegate = self
        switch currentGardener.type {
        case "cle_en_main":
            cell.stageName.text = "\(NSLocalizedString("level", comment: "level")) \(stageNumber)"
            cell.stageImage.image = UIImage(named: "etage\(self.currentGardenerStage)\(stageNumber)")
        case "carre":
            cell.stageName.text = "\(NSLocalizedString("row", comment: "row")) \(stageNumber)"
            cell.stageImage.image = UIImage(named: "rang\(self.currentGardenerStage)-\(stageNumber)")
        case "capteur_carre":
            cell.stageName.text = "\(NSLocalizedString("row", comment: "row")) \(stageNumber)"
            cell.stageImage.image = UIImage(named: "rang\(self.currentGardenerStage)-\(stageNumber)")
        case "parcelle":
            if (stageNumber <= currentGardener.rangs) {
                switch stageNumber {
                case 2:
                    cell.stageName.text = "\(NSLocalizedString("row", comment: "row")) 2"
                    cell.stageImage.image = UIImage(named: "rang2-1")
                case 1:
                    cell.stageName.text = "\(NSLocalizedString("row", comment: "row")) 1"
                    cell.stageImage.image = UIImage(named: "rang2-2")
                default:
                    cell.stageName.text = "\(NSLocalizedString("row", comment: "row")) 1"
                    cell.stageImage.image = UIImage(named: "rang2-1")
                }
            } else {
                cell.stageName.text = "\(NSLocalizedString("level", comment: "level")) \(stageNumber - currentGardener.rangs)"
                cell.stageImage.image = UIImage(named: "etage\(self.currentGardenerStage)\(stageNumber - currentGardener.rangs)")
            }

        default:
            cell.stageName.text = currentGardener.metadata.name
            setImageGenericPlantsVC(gardener: currentGardener, ivCenter: cell.stageImage)
        }
        cell.stage = indexPath.row
        cell.stageRow = setNumberOfRowOfType(currentGardener)
        cell.plantsModel = self.plantsService.plants
        cell.plants = self.allPlants
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = bgColorView
        
        cell.gardenerId = self.currentGardener
        cell.collectionView.reloadData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 230
    }
}

extension PlantsVC: GardenerFloorTCellDelegate {
    
    func didPopModalAddPlant(key: String, gardenerId: String) {
        let controller = StoryboardScene.MyPlants.addPlantSearchVC.instantiate()
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        controller.key = key
        controller.gardener = self.currentGardenerModel
        controller.gardenerId = self.currentGardener
        controller.allPlants = self.allPlants
        self.present(controller, animated: true, completion: nil)
    }
    
    func didPopModalInfoPlant(key: String, gardenerId: String, plant: GardenerPlantModel) {

        performSegue(withIdentifier: "goToInfoDescriptionPlantVC", sender: key)
    }
}
