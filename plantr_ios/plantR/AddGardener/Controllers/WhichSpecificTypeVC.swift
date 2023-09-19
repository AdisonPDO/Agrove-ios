//
//  WhichSpecificTypeVC.swift
//  plantR_ios
//
//  Created by Boris Roussel on 25/05/2021.
//  Copyright © 2021 Agrove. All rights reserved.
//

import UIKit

class WhichSpecificTypeVC: UIViewController {
    
    @IBOutlet var cvSelectingAgrove: UICollectionView!
    @IBOutlet var lTypeTitle: UILabel!
    @IBOutlet var vContainer: CornerRaduisV!
    let allType = [
        GardenerType.KitCapteur : [
            SpecificTypeStructValue(type: .kitCapteur, image: "kit_capteur", text: NSLocalizedString("the_sensor_kit", comment: "the sensor kit"), desc: ""),
            SpecificTypeStructValue(type: .kitMural, image: "kit_mural", text: NSLocalizedString("the_wall_kit", comment: "the wall kit"), desc: ""),
            SpecificTypeStructValue(type: .kitCleEnMain, image: "kit_cle_main", text: NSLocalizedString("the_turnkey_kit", comment: "the turnkey kit"), desc: ""),
            SpecificTypeStructValue(type: .kitParcelle, image: "parcelle", text: NSLocalizedString("the_parcel", comment: "the parcel"), desc: "")
        ],
        GardenerType.Carre : [
            SpecificTypeStructValue(type: .carrePetit, image: "petit_carre_potager", text: NSLocalizedString("small", comment: "small"), desc: NSLocalizedString("up_to_small", comment: "size")),
            SpecificTypeStructValue(type: .carreMoyen, image: "moyen_carre_potager", text: NSLocalizedString("medium", comment: "medium"), desc: NSLocalizedString("up_to_medium", comment: "size")),
            SpecificTypeStructValue(type: .carreGrand, image: "grand_carre_potager", text: NSLocalizedString("big", comment: "big"), desc: NSLocalizedString("up_to_big", comment: "size"))
        ],
        GardenerType.Jardinière :[
            SpecificTypeStructValue(type: .jardinierePetite, image: "jardiniere_petit_taille",text: NSLocalizedString("small", comment: "small"), desc: NSLocalizedString("up_to", comment: "up to")),
            SpecificTypeStructValue(type: .jardiniereMoyen, image: "jardiniere_moyen_taille",text: NSLocalizedString("medium", comment: "medium"), desc: NSLocalizedString("up_to", comment: "up to")),
            SpecificTypeStructValue(type: .jardiniereGrand, image: "jardiniere_grand_taille",text: NSLocalizedString("big", comment: "big"), desc: NSLocalizedString("starting_from", comment: "starting from"))
        ],
        GardenerType.Pot: [
            SpecificTypeStructValue(type: .potPetit, image: "pot_petit_taille",text: NSLocalizedString("small", comment: "small"), desc: NSLocalizedString("up_to", comment: "up to")),
            SpecificTypeStructValue(type: .potMoyen, image: "pot_moyen_taille",text: NSLocalizedString("medium", comment: "medium"), desc: NSLocalizedString("up_to", comment: "up to")),
            SpecificTypeStructValue(type: .potGrand, image: "pot_grand_taille",text: NSLocalizedString("big", comment: "big"), desc: NSLocalizedString("starting_from", comment: "starting from"))
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let blurredView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurredView.frame = self.view.bounds
        self.view.addSubview(blurredView)
        self.view.bringSubviewToFront(vContainer)
        
        switch AddGardenerService.shared.selectingTypeStruct?.type {
        case GardenerType.KitCapteur:
            self.lTypeTitle.text = NSLocalizedString("how_big_is_your_planter", comment: "how big is your planter")
        case GardenerType.Carre:
            self.lTypeTitle.text = NSLocalizedString("how_big_is_your_vegetable_patch", comment: "how big is your vegetable patch")
        case GardenerType.Jardinière:
            self.lTypeTitle.text = NSLocalizedString("how_big_is_your_planter", comment: "how big is your planter")
        case GardenerType.Pot:
            self.lTypeTitle.text = NSLocalizedString("how_big_is_your_pot", comment: "how big is your pot")
        default:
            self.lTypeTitle.text = NSLocalizedString("how_big_is_your_planter", comment: "how big is your planter")
        }
        self.cvSelectingAgrove.delegate = self
        self.cvSelectingAgrove.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    fileprivate func getWhichType() -> [SpecificTypeStructValue] {
        switch AddGardenerService.shared.selectingTypeStruct?.type {
        case GardenerType.KitCapteur:
            return self.allType[GardenerType.KitCapteur]!
        case GardenerType.Carre:
            return self.allType[GardenerType.Carre]!
        case GardenerType.Jardinière:
            return self.allType[GardenerType.Jardinière]!
        case GardenerType.Pot:
            return self.allType[GardenerType.Pot]!
        default:
            return []
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension WhichSpecificTypeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch AddGardenerService.shared.selectingTypeStruct?.type {
        case GardenerType.KitCapteur:
            return self.allType[GardenerType.KitCapteur]!.count
        case GardenerType.Carre:
            return self.allType[GardenerType.Carre]!.count
        case GardenerType.Jardinière:
            return self.allType[GardenerType.Jardinière]!.count
        case GardenerType.Pot:
            return self.allType[GardenerType.Pot]!.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let specificType = self.getWhichType()[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sizeSelectingTypeCVC", for: indexPath) as! SizeSelectingTypeCVC
        cell.type = specificType.type
        cell.ivType.image = UIImage(named: specificType.image)
        cell.lTitle.text = specificType.text
        cell.ldesc.text = specificType.desc
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch AddGardenerService.shared.selectingTypeStruct?.type {
        case GardenerType.KitCapteur:
            //            self.performSegue(withIdentifier: "", sender: nil)
            AddGardenerService.shared.selectingTypeStruct = nil
            break
        case GardenerType.Carre:
            AddGardenerService.shared.sizeType = self.allType[GardenerType.Carre]![indexPath.row].type
            print("TYPE Size selected => \(AddGardenerService.shared.sizeType)")
            if (AddGardenerService.shared.kitAgrove) {
                self.performSegue(withIdentifier: "goToScanningVC", sender: nil)
            } else {
                self.performSegue(withIdentifier: "goToValidateVC", sender: nil)
            }
        case GardenerType.Jardinière:
            AddGardenerService.shared.sizeType = self.allType[GardenerType.Jardinière]![indexPath.row].type
            print("TYPE Size selected => \(AddGardenerService.shared.sizeType)")
            if (AddGardenerService.shared.kitAgrove) {
                self.performSegue(withIdentifier: "goToScanningVC", sender: nil)
            } else {
                self.performSegue(withIdentifier: "goToValidateVC", sender: nil)
            }
        case GardenerType.Pot:
            AddGardenerService.shared.sizeType = self.allType[GardenerType.Pot]![indexPath.row].type
            print("TYPE Size selected => \(AddGardenerService.shared.sizeType)")
            if (AddGardenerService.shared.kitAgrove) {
                self.performSegue(withIdentifier: "goToScanningVC", sender: nil)
            } else {
                self.performSegue(withIdentifier: "goToValidateVC", sender: nil)
            }
        default:
            AddGardenerService.shared.selectingTypeStruct = nil
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = (collectionView.bounds.width / 2) - 20
        return CGSize(width: screenWidth, height: screenWidth)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 6.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
}
