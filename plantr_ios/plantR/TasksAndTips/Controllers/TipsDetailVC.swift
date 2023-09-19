//
//  TipsDetailVC TipsDetailVC TipsDetailVC.swift
//  plantR_ios
//
//  Created by Rabissoni on 29/03/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit
import Firebase

class TipsDetailVC: UIViewController {
    @IBOutlet var nameTipsLabel: UILabel!
    @IBOutlet var descriptionTipsLabel: UILabel!
    @IBOutlet var nameGoodTipsLabel: UILabel!
    @IBOutlet var descriptionGoodTipsLabel: UILabel!
    @IBOutlet var nameBadTipsLabel: UILabel!
    @IBOutlet var descriptionBadTipsLabel: UILabel!
    @IBOutlet weak var ivTips: UIImageView!
    
    var gardenerRepository: GardenerRepository!
    var tipsService: TipsService!
    
    private var gardenerTipsReference: DatabaseReference!
    
    var gardenerId: String?
    var nameOfAlert: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let gardenerId = gardenerId, let nameOfAlert = nameOfAlert else { return }
        self.gardenerTipsReference = self.gardenerRepository.getGardenerTipsReference(by: gardenerId).child(nameOfAlert)
        print(self.gardenerTipsReference)
        let tips = self.tipsService.getTipsBy(name: nameOfAlert)
        switch nameOfAlert {
        case "waterLevel":
            if let image = UIImage(named: "alerte_water_level") {
                self.ivTips.image = image
            }
        default:
            if let image = UIImage(named: "iconeCercleTips") {
                self.ivTips.image = image
            }
        }
        self.descriptionTipsLabel.text = tips.description
        self.nameTipsLabel.text = tips.name
        self.nameGoodTipsLabel.text = tips.goodTips
        self.nameBadTipsLabel.text = tips.badTips
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goodTapped(_ sender: Any) {
        self.gardenerTipsReference.setValue(false) { (error, _) in
            if error != nil {
                print(error)
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func notGoodTapped(_ sender: Any) {
        self.gardenerTipsReference.setValue(false) { (error, _) in
            if error != nil {
                print(error)
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
}
