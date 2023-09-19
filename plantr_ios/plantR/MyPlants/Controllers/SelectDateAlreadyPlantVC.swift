//
//  SelectDateAlreadyPlantVC.swift
//  plantR_ios
//
//  Created by Boris Roussel on 05/03/2021.
//  Copyright © 2021 Agrove. All rights reserved.
//

import UIKit

class SelectDateAlreadyPlantVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!
    
    var plantID: String?
    var gardenerId: String?
    var location: String?
    var sowing: Bool?
    var plant: (plantName: String, plantInfo: InfosPlants)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let sowing = sowing else { return }
        if (sowing) {
            titleLabel.text = NSLocalizedString("when_did_you_sow_it", comment: "when_did_you_sow_it")
        } else {
            titleLabel.text = NSLocalizedString("when_did_you_plant_it", comment: "when_did_you_plant_it")
        }
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = UIDatePickerStyle.wheels
        } else {
            // Fallback on earlier versions
        }
        datePicker.date = Date()
        datePicker.maximumDate = Date()
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmTapped(_ sender: UIButton) {
        var numberOfDay = getNumberOfDay(previous: datePicker.date, current: Date())
        switch numberOfDay {
        case 0:
            self.popOKAlertController(title: NSLocalizedString("you_must_select_a_date_before_today", comment: "you_must_select_a_date_before_today"))
        default:
            setPlantOnPosition(numberOfDay: numberOfDay)
        }
    }
    
    private func getNumberOfDay(previous: Date, current: Date) -> Int {
        let daysOptional = Calendar.current.dateComponents([.day], from: previous, to: current).day
        if let days = daysOptional {
            return days
        } else {
            return 0
        }
    }
    
    private func setPlantOnPosition(numberOfDay: Int) {
        guard let gardenerId = gardenerId, let plantId = plantID, let key = location, let infoPlantSure = plant?.plantInfo, let name: String? = infoPlantSure.infoPlant.name else { return }
        let toAdd = self.gardenerTransformer.toDictionaryToAddPlantPreviousDate(name ?? plantId.capitalized, plantID: plantId, previousDate: numberOfDay)
        self.gardenerRepository.getPlantingToAddPreviousDate(by: gardenerId, by: key).setValue(toAdd) { (error, _) in
            self.popOKAlertController(title: NSLocalizedString("the_plant_has_been_added", comment: "the_plant_has_been_added"), message: nil, okHandler: { (_ ) in
                self.performSegue(withIdentifier: "unwindSegueToPlantsVC", sender: nil)
            })
        }
    }
}
