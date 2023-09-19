//
//  InfoPlantMyPlantsVC.swift
//  plantR_ios
//
//  Created by Mathieu Rabissoni on 15/04/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class InfoPlantMyPlantsVC: UIViewController {
    
    @IBOutlet var deletePicture: UIButton!
    @IBOutlet var imagePlant: UIImageView!
    @IBOutlet var imageTake: UIButton!
    @IBOutlet var infoPlantViewUIView: InfoPlantsView!
    @IBOutlet var namePlantProgressLabel: UILabel!
    @IBOutlet weak var startSowingPlantsLabel: UILabel!
    @IBOutlet weak var growingTimeLabel: UILabel!
    @IBOutlet weak var arriveHarvestLabel: UILabel!
    @IBOutlet weak var growingTimeProgressBar: UIProgressView!
    
    private var handlePicture: UInt?
    private var picturePlantRef: DatabaseReference!
    
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!
    
    var plantsService: PlantsService!
    var plant: GardenerPlantModel?
    var key: String?
    var gardenerId: String?
    
    enum ImageSource {
        case photoLibrary
        case camera
    }
    
    var widthPictureCell: CGFloat = 0.0
    lazy var imagePicker: UIImagePickerController = {
        let imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        return imagePicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let plant = plant else { return }
        guard let plantModel = self.plantsService.plants[plant.plantID] else { return }

        let dayTimeSowing = DateFormatter()
        dayTimeSowing.locale = Locale(identifier: NSLocalizedString("local_identifier", comment: "local_identifier"))
        dayTimeSowing.dateFormat = "dd/MM/YYYY"
        
        let dayTimeHarvested = DateFormatter()
        dayTimeHarvested.locale = Locale(identifier: NSLocalizedString("local_identifier", comment: "local_identifier"))
        dayTimeHarvested.dateFormat = "dd/MM/YYYY"
        let dateSowing = plant.dateSowing
        let dateHarvested = plant.dateHarvested
        
        self.startSowingPlantsLabel.text = dayTimeSowing.string(from: dateSowing).capitalized
        self.arriveHarvestLabel.text = "\(NSLocalizedString("estimated_harvest", comment: "estimated_harvest")) \n\(dayTimeHarvested.string(from: dateHarvested).capitalized)"
        
        let dateHarvest = Double(plant.dateHarvested.timeIntervalSince1970)
        let dateNow = Double(Date().timeIntervalSince1970)
        let dayLeft = Int(dateHarvest - dateNow) / (3600 * 24)
        
        if plant.plantName == "" {
            self.namePlantProgressLabel.text = plantModel.infoPlant.name
        } else {
            self.namePlantProgressLabel.text = plant.plantName
        }
        self.growingTimeLabel.text = howManyDays(time: dayLeft)
        infoPlantViewUIView.setHarvestSowingInfo(plantModel: plantModel)
        setProgressBar(start: plant.dateSowing.timeIntervalSince1970, end: plant.dateHarvested.timeIntervalSince1970, current: Date().timeIntervalSince1970)
        self.picturePlantRef = self.gardenerRepository.getPlantStageAndRowPictureReference(by: gardenerId!, by: key!)
       
        self.picturePlantRef.observeSingleEvent(of: .value, with: { (snapPicture) in
            let picture = snapPicture.value as! Bool
            if let gardenerId = self.gardenerId, let key = self.key, let plant = self.plant, let plantModel = self.plantsService.plants[plant.plantID] {
                guard picture != true else {
                    let storagePicture = self.gardenerRepository.getGardenerPlantStageAndRowStorage(by: gardenerId, by: key)
                    self.imagePlant.sd_setImage(with: storagePicture)
                    return
                }
                self.deletePicture.isHidden = true
                self.imagePlant.sd_setImage(with: plantModel.imagePlant)
                
            }
        })
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        guard let headerView = infoPlantViewUIView.tableView.tableHeaderView else {
//            return
//        }
//
//        let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
//        if headerView.frame.size.height != size.height {
//            headerView.frame.size.height = size.height
//            infoPlantViewUIView.tableView.tableHeaderView = headerView
//            infoPlantViewUIView.tableView.layoutIfNeeded()
//        }
//    }
    
    @IBAction func deletePlantAction(_ sender: Any) {
        guard let id = gardenerId, let plantKey = key else {
            return
        }
        
        let alerteActionSheet = UIAlertController(title: nil, message: NSLocalizedString("do_you_really_want_to_remove_this_plant", comment: "do_you_really_want_to_remove_this_plant"), preferredStyle: .alert)
        alerteActionSheet.view.tintColor = Styles.PlantRBlackColor
        let delete = UIAlertAction(title: NSLocalizedString("remove", comment: "remove"), style: .default) { _ in
            let plant = self.gardenerRepository.removePlant(by: id, by: plantKey)
            plant.removeValue { (error, _) in
                if error != nil {
                    self.popOKAlertController(title: NSLocalizedString("an_error_has_occurred", comment: "an_error_has_occurred"))
                } else {
                    self.popOKAlertController(title: NSLocalizedString("your_plant_has_been_deleted", comment: "your_plant_has_been_deleted"), message: nil) { (_) in
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
        let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: nil)
        alerteActionSheet.addAction(delete)
        alerteActionSheet.addAction(cancel)
        present(alerteActionSheet, animated: true, completion: nil)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func presentWithSource(_ source: UIImagePickerController.SourceType) {
        imagePicker.sourceType = source
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func addPictureTapped(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            self.presentWithSource(.photoLibrary)
            return
        }
        let alerteActionSheet = UIAlertController(title: "", message: NSLocalizedString("select_a_category", comment: "select_a_category"), preferredStyle: .actionSheet)
        alerteActionSheet.view.tintColor = Styles.PlantRBlackColor
        let camera = UIAlertAction(title: NSLocalizedString("camera", comment: "camera"), style: .default) { _ in
            self.presentWithSource(.camera)
        }
        let gallery = UIAlertAction(title: NSLocalizedString("photo_gallery", comment: "photo_gallery"), style: .default) { _ in
            self.presentWithSource(.photoLibrary)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: nil)
        alerteActionSheet.addAction(camera)
        alerteActionSheet.addAction(gallery)
        alerteActionSheet.addAction(cancel)
        
        if let popover = alerteActionSheet.popoverPresentationController {
            popover.sourceView = imageTake.superview
            popover.sourceRect = imageTake.frame
        }
        present(alerteActionSheet, animated: true, completion: nil)
    }
    
    @IBAction func deletePictureTapped(_ sender: Any) {
        
        if let gardenerId = gardenerId, let key = key {
            
            let alerteActionSheet = UIAlertController(title: nil, message: NSLocalizedString("do_you_really_want_to_delete_this_picture", comment: "do_you_really_want_to_delete_this_picture"), preferredStyle: .alert)
            
            alerteActionSheet.view.tintColor = Styles.PlantRBlackColor
            
            let delete = UIAlertAction(title: NSLocalizedString("remove", comment: "remove"), style: .default) { _ in
                
                if let plant = self.plant, let plantModel = self.plantsService.plants[plant.plantID] {
                    let pictureDatabaseRef = self.gardenerRepository.getPlantStageAndRowPictureReference(by: gardenerId, by: key)
                    self.gardenerRepository.getGardenerPlantStageAndRowStorage(by: gardenerId, by: key).delete { error in
                        if let error = error {
                            print(error)
                        } else {
                            pictureDatabaseRef.setValue(false)
                            self.deletePicture.isHidden = true
                            self.imagePlant.sd_setImage(with: plantModel.imagePlant)
                        }
                    }
                }
            }
            
            let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: nil)
            alerteActionSheet.addAction(delete)
            alerteActionSheet.addAction(cancel)
            present(alerteActionSheet, animated: true, completion: nil)
        }
    }
    
    @IBAction func taskTapped(_ sender: Any) {
        
        guard let gardenerId = self.gardenerId, let key = key, let plant = self.plant, let plantModel = self.plantsService.plants[plant.plantID] else { return }
        
        let controller = StoryboardScene.TasksAndTips.allTasksVC.instantiate()
        
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        controller.plant = plant
        controller.plantModel = plantModel
        controller.gardenerId = gardenerId
        controller.plantUID = plant.plantID
        controller.key = key
        
        self.present(controller, animated: true, completion: nil)
    }
    
    func setProgressBar(start: Double, end: Double, current: Double) {
        let dProgress = Float((current - start) / (end - start))
        growingTimeProgressBar.setProgress(dProgress, animated: true)
    }
    
    func monthFormat(month: String) -> String {
        guard month != "0" else { return "" }
        return "\(month) \(NSLocalizedString("month", comment: "month"))"
    }
    
    func dayFormat(day: String) -> String {
        guard day != "0" else { return "" }
        guard day != "1" else { return "\(day) \(NSLocalizedString("day", comment: "day"))" }
        return "\(day) \(NSLocalizedString("days", comment: "days"))"
    }
    
    func howManyDays(time: Int) -> String {
        let month = String(time / 30)
        let day = String(time % 30)
        let monthFormat = self.monthFormat(month: month)
        let dayFormat = self.dayFormat(day: day)
        guard monthFormat != "" else { return dayFormat + "\(NSLocalizedString("remaining", comment: "remaining"))" }
        return "\(monthFormat) \(dayFormat) \(NSLocalizedString("remaining", comment: "remaining"))"
    }
}

extension InfoPlantMyPlantsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let originale = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let key = key, let gardenerId = gardenerId {
            guard let data = originale.jpegData(compressionQuality: 0.1) else { return }
            let pictureDatabaseRef = self.gardenerRepository.getPlantStageAndRowPictureReference(by: gardenerId, by: key)
            self.imagePlant.image = originale
            let storageImageRef = self.gardenerRepository.getGardenerPlantStageAndRowStorage(by: gardenerId, by: key)
            storageImageRef.putData(data, metadata: nil, completion: { (_, error) in
                if let error = error {
                    print(error)
                    return
                }
                pictureDatabaseRef.setValue(true, withCompletionBlock: { (_, _) in
                    self.deletePicture.isHidden = false
                })
            })
        }
        dismiss(animated: true, completion: nil)
    }
}
