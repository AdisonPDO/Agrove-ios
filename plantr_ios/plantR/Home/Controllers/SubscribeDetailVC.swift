//
//  SubscribeDetailVC.swift
//  plantR_ios
//
//  Created by Boris Roussel on 07/09/2020.
//  Copyright © 2020 Rabissoni. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class SubscribeDetailVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var collectionViewPicture: UICollectionView!
    @IBOutlet var leftArrowButton: UIButton!
    @IBOutlet var rightArrowButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    
    private var dataSourceImages: FUICollectionViewDataSource!
    private var numberOfPictures: Int!
    private var currentPicture: Int!
    
    private var detailGardenerRef: DatabaseReference!
    private var gardenerImagesRef: DatabaseReference!
    private var gardenerPictureRef: StorageReference!
    private var allPlantsGardenerRef: DatabaseReference!

    var plantsService: PlantsService!
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!
    
    var currentGardener: String!
    var currentGardenerModel: GardenerModel? = nil
    var stageGardener: Int = 0
    private var allPlants: [String: GardenerPlantModel] = [:]
    var widthPictureCell: CGFloat = 0.0
    
    private var handleCurrentGardener: UInt?
    private var handlePictures: UInt?
    private var handleGardener: UInt?
    
    override func viewDidLoad() {
        print("Ici j'ai en détail => \(currentGardener)")
        self.detailGardenerRef = self.gardenerRepository.getReference(for: self.currentGardener)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.handleCurrentGardener = self.detailGardenerRef.observe(.value, with: { (snapshot) in
            var gardenerModel = self.gardenerTransformer.toGardenerModel(snap: snapshot)
            self.currentGardenerModel = gardenerModel
            self.currentPicture = 0
            self.stageGardener = Int(gardenerModel.stage) ?? 0
            self.gardenerImagesRef = self.gardenerRepository.getMetadataImagesReference(by: gardenerModel.id)
            self.headerView.isHidden = false
            

            self.handlePictures = self.gardenerImagesRef.observe(.value, with: { (snapshot) in
                let pictures = snapshot.value as? [String: Any] ?? [:]
                self.numberOfPictures = pictures.count
                guard self.numberOfPictures > 2 else {
                    self.rightArrowButton.isHidden = true
                    self.leftArrowButton.isHidden = true
                    return
                }
                self.rightArrowButton.isHidden = false

            })
            
            self.dataSourceImages = self.collectionViewPicture.bind(to: self.gardenerImagesRef, populateCell: { (_ collectionView, _ indexPath, _ snapPictures) -> UICollectionViewCell in
                let cell = self.collectionViewPicture.dequeueReusableCell(withReuseIdentifier: "pictureCell", for: indexPath) as! HeaderDashboardPictureCell
                let picture = snapPictures.key
                cell.idPicture = picture
                cell.delegate = self
                cell.imagePicture.sd_setImage(with: self.gardenerRepository.getGardenerImage(by: self.currentGardener, name: "\(picture).jpg"))
                return cell
            })
            
            self.allPlantsGardenerRef = self.gardenerRepository.getAllPlantsReference(by: self.currentGardener)
            self.handleGardener = self.allPlantsGardenerRef.observe(.value, with: { (snapPlants) in
                let plants = snapPlants.value as? [String: Any] ?? [:]
                let plantsFormated = plants.mapValues { self.gardenerTransformer.toGardenerPlantModel($0 as! [String: Any]) }
                self.allPlants = plantsFormated
                self.tableView.reloadData()
            })
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if UIDevice.current.userInterfaceIdiom == .pad {
            widthPictureCell = self.collectionViewPicture.bounds.width * 0.5
            self.collectionViewPicture.isScrollEnabled = false
        } else {
            widthPictureCell = self.collectionViewPicture.bounds.width * 0.7
        }
        if let flowLayout = self.collectionViewPicture.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: widthPictureCell, height: self.collectionViewPicture.bounds.height)
        }
    }

    
    @IBAction func backTapped(_ sender: UIButton) {
        if let navC = navigationController {
            navC.popViewController(animated: true)
        } else {
            self.performSegue(withIdentifier: "backFromSubscribeDetailVC", sender: nil)
        }
//        }
    }
    
    @IBAction func arrowTapped(_ sender: UIButton) {
        sender.isEnabled = false
        let currentGardenerIndex = self.currentPicture!
        if sender == leftArrowButton {
            self.selectPicture(currentGardenerIndex - 1, animated: true)
        }
        if sender == rightArrowButton {
            self.selectPicture(currentGardenerIndex + 1, animated: true)
        }
        sender.isEnabled = true
    }
    
    
    private func selectPicture(_ index: Int, animated: Bool) {
        guard index != self.dataSourceImages.items.count else {
            self.currentPicture -= 1
            self.rightArrowButton.isHidden = true
            return
        }
        if index == 0 {
            self.rightArrowButton.isHidden = false
            self.leftArrowButton.isHidden = true
        } else if index + 1 == self.numberOfPictures - 1 {
            self.leftArrowButton.isHidden = false
            self.rightArrowButton.isHidden = true
        } else {
            self.rightArrowButton.isHidden = false
            self.leftArrowButton.isHidden = false
        }
        let indexPath = IndexPath(item: index, section: 0)
        self.collectionViewPicture.scrollToItem(at: indexPath, at: .left, animated: animated)
        self.currentPicture = index
    }
    
}

extension SubscribeDetailVC: HeaderDashboardPictureCellDelegate {
    func didDeletePicture(named: String) {
        print("delete")
    }
}

extension SubscribeDetailVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stageGardener + (self.currentGardenerModel?.rangs ?? 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gardenerFloorCell", for: indexPath) as! GardenerFloorTCell
        guard let currentGardener = currentGardenerModel else { return cell }
        let stageNumber = (self.stageGardener + currentGardener.rangs) - indexPath.row
        cell.delegate = self
        switch currentGardener.type {
        case "cle_en_main":
            cell.stageName.text = "\(NSLocalizedString("level", comment: "level")) \(stageNumber)"
            cell.stageImage.image = UIImage(named: "etage\(self.stageGardener)\(stageNumber)")
        case "carre","capteur_carre":
            cell.stageName.text = "\(NSLocalizedString("row", comment: "row")) \(stageNumber)"
            cell.stageImage.image = UIImage(named: "rang\(self.stageGardener)-\(stageNumber)")
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
                cell.stageImage.image = UIImage(named: "etage\(self.stageGardener)\(stageNumber - currentGardener.rangs)")
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
        /*
         BEFORE
         guard let currentGardener = currentGardenerModel else { return cell }
        let stageNumber = String(stageGardener - indexPath.row)
        cell.delegate = self
        cell.visited = true
        switch currentGardener.type {
        case "cle_en_main":
            cell.stageName.text = "Etage \(stageNumber)"
            cell.stageImage.image = UIImage(named: "etage\(stageGardener)\(stageNumber)")
        case "carre":
            cell.stageName.text = "Rangée \(stageNumber)"
            cell.stageImage.image = UIImage(named: "rang\(stageGardener)\(stageNumber)")
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
        cell.collectionView.reloadData()*/
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 230
    }
}

extension SubscribeDetailVC: GardenerFloorTCellDelegate {
    func didPopModalAddPlant(key: String, gardenerId: String) {
        print("ADD")
    }
    
    func didPopModalInfoPlant(key: String, gardenerId: String, plant: GardenerPlantModel) {
        print("INFO")
    }
}
