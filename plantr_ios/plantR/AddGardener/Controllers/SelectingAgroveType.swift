//
//  SelectingAgroveType.swift
//  plantR_ios
//
//  Created by Boris Roussel on 01/06/2021.
//  Copyright © 2021 Agrove. All rights reserved.
//

import UIKit

class SelectingAgroveType: UIViewController {
    
    @IBOutlet var cvSelectingAgrove: UICollectionView!
    @IBOutlet var vContainer: CornerRaduisV!
    
    let allType = [
        GardenerType.KitCapteur : [
            SpecificTypeStructValue(type: .kitCapteur, image: "kit_capteur", text: NSLocalizedString("the_sensor_kit", comment: "the sensor kit"), desc: ""),
            SpecificTypeStructValue(type: .kitMural, image: "kit_mural", text: NSLocalizedString("the_wall_kit", comment: "the wall kit"), desc: ""),
            SpecificTypeStructValue(type: .kitCleEnMain, image: "kit_cle_main", text: NSLocalizedString("the_turnkey_kit", comment: "the turnkey kit"), desc: ""),
            SpecificTypeStructValue(type: .kitParcelle, image: "parcelle", text: NSLocalizedString("the_parcel", comment: "the parcel"), desc: "")
        ],
        GardenerType.Carre : [
            SpecificTypeStructValue(type: .carrePetit, image: "petit_carre_potager", text: NSLocalizedString("small", comment: "small"), desc: NSLocalizedString("up_to_50_cm", comment: "size")),
            SpecificTypeStructValue(type: .carreMoyen, image: "moyen_carre_potager", text: NSLocalizedString("medium", comment: "medium"), desc: NSLocalizedString("up_to_75_cm", comment: "size")),
            SpecificTypeStructValue(type: .carreGrand, image: "grand_carre_potager", text: NSLocalizedString("big", comment: "big"), desc: NSLocalizedString("more_than_1m2", comment: "size"))
        ],
        GardenerType.Jardinière :[
            SpecificTypeStructValue(type: .jardinierePetite, image: "jardiniere_petit_taille",text: NSLocalizedString("small_f", comment: "small"), desc: NSLocalizedString("up_to", comment: "up to")),
            SpecificTypeStructValue(type: .jardiniereMoyen, image: "jardiniere_moyen_taille",text: NSLocalizedString("medium_f", comment: "medium"), desc: NSLocalizedString("up_to", comment: "up to")),
            SpecificTypeStructValue(type: .jardiniereGrand, image: "jardiniere_grand_taille",text: NSLocalizedString("big_f", comment: "big"), desc: NSLocalizedString("up_to", comment: "up to"))
        ],
        GardenerType.Pot: [
            SpecificTypeStructValue(type: .potPetit, image: "pot_petit_taille",text: NSLocalizedString("small", comment: "small"), desc: NSLocalizedString("up_to", comment: "up to")),
            SpecificTypeStructValue(type: .potMoyen, image: "pot_moyen_taille",text: NSLocalizedString("medium", comment: "medium"), desc: NSLocalizedString("up_to", comment: "up to")),
            SpecificTypeStructValue(type: .potGrand, image: "pot_grand_taille",text: NSLocalizedString("big", comment: "big"), desc: NSLocalizedString("up_to", comment: "up to"))
        ]
    ]
    var type: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let blurredView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurredView.frame = self.view.bounds
        self.view.addSubview(blurredView)
        self.view.bringSubviewToFront(vContainer)
        self.cvSelectingAgrove.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func ibBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SelectingAgroveType: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.allType[GardenerType.KitCapteur]!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let specificType = self.allType[GardenerType.KitCapteur]![indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectingAgroveType", for: indexPath) as! SelectingAgroveTypeCVC
        cell.type = specificType.type
        cell.ivType.image = UIImage(named: specificType.image)
        cell.lTitle.text = specificType.text
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.allType[GardenerType.KitCapteur]![indexPath.row].type == .kitCapteur {
            self.performSegue(withIdentifier: "goToTypeSelectVC", sender: nil)
        } else {
            let sender: [String: Any?] = ["name": "My name", "id": 10]
            self.performSegue(withIdentifier: "goToScanningVC", sender: sender)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = (collectionView.bounds.width / 2) - 18
        return CGSize(width: screenWidth, height: screenWidth)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 6.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
}
