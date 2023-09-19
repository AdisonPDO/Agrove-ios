//
//  InfoPlantsVC.swift
//  plantR_ios
//
//  Created by Mathieu Rabissoni on 16/04/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit

class InfoPlantsVC: UIViewController {

    @IBOutlet weak var infoPlantXIB:  InfoPlantsView!
    
    var plant: (plantName: String, plantInfo: InfosPlants)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let plant = plant else { return }
        infoPlantXIB.setHarvestSowingInfo(plantModel: plant.plantInfo)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
