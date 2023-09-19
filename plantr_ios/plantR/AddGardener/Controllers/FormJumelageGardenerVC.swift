//
//  FormJumelageGardenerVC.swift
//  plantR_ios
//
//  Created by Boris Roussel on 22/06/2021.
//  Copyright © 2021 Agrove. All rights reserved.
//


import UIKit
import CoreLocation
import FirebaseUI
import FirebaseAuth

let SunArray = [NSLocalizedString("please_select_a_type_of_sunlight", comment: "please_select_a_type_of_sunlight"),NSLocalizedString("shadow_all_day_long", comment: "shadow_all_day_long"),NSLocalizedString("sun_in_the_morning", comment: "sun_in_the_morning"), NSLocalizedString("sun_in_the_afternoon", comment: "sun_in_the_afternoon"), NSLocalizedString("sun_all_day_long", comment: "sun_all_day_long")]

let PlacesArray = [NSLocalizedString("please_select_a_location", comment: "please_select_a_location"),NSLocalizedString("garden", comment: "garden"),NSLocalizedString("terasse", comment: "terasse"), NSLocalizedString("balcony", comment: "balcony"), NSLocalizedString("window_railing", comment: "window_railing"), NSLocalizedString("inside", comment: "inside")]

let OrientArray = [NSLocalizedString("please_select_a_location", comment: "please_select_a_location"),NSLocalizedString("north", comment: "north"), NSLocalizedString("south", comment: "south"), NSLocalizedString("east", comment: "east"), NSLocalizedString("west", comment: "west"), NSLocalizedString("south_east", comment: "south east"), NSLocalizedString("north_east", comment: "north east"), NSLocalizedString("south_west", comment: "south west"), NSLocalizedString("north_west", comment: "north west")]

let SunArrayWithoutSelecting = [NSLocalizedString("undefined", comment: "undefined"),NSLocalizedString("shadow_all_day_long", comment: "shadow_all_day_long"),NSLocalizedString("sun_in_the_morning", comment: "sun_in_the_morning"), NSLocalizedString("sun_in_the_afternoon", comment: "sun_in_the_afternoon"), NSLocalizedString("sun_all_day_long", comment: "sun_all_day_long")]

let PlacesArrayWithoutSelecting = [NSLocalizedString("undefined", comment: "undefined"),NSLocalizedString("garden", comment: "garden"),NSLocalizedString("terasse", comment: "terasse"), NSLocalizedString("balcony", comment: "balcony"), NSLocalizedString("window_railing", comment: "window_railing"), NSLocalizedString("inside", comment: "inside")]

let OrientArrayWithoutSelecting = [NSLocalizedString("undefined", comment: "undefined"),NSLocalizedString("north", comment: "north"), NSLocalizedString("south", comment: "south"), NSLocalizedString("east", comment: "east"), NSLocalizedString("west", comment: "west"), NSLocalizedString("south_east", comment: "south east"), NSLocalizedString("north_east", comment: "north east"), NSLocalizedString("south_west", comment: "south west"), NSLocalizedString("north_west", comment: "north west")]


class FormJumelageGardenerVC: UIViewController, DataPickerTextFieldDelegate {
    var dismissDelegate: DismissDelegate?
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!
    var userRepository: UserRepository!
    var userTransformer: UserTransformer!
    var pays = PaysUtils()
    
    func didSelectRow(pickerView: UIPickerView, row: Int, component: Int, identifier: String, value: String) {
        if identifier == FormPickerType.Sun {
            indexSun = row
        }
        if identifier == FormPickerType.Place {
            indexPlace = row
        }
        if identifier == FormPickerType.Orientation {
            indexOrient = row
        }
    }
    
    @IBOutlet var bLocation: UIButton!
    @IBOutlet var tfPlace: DataPickerTextField!
    @IBOutlet var tfSun: DataPickerTextField!
    @IBOutlet var tfOrient: DataPickerTextField!
    @IBOutlet var lName: UILabel!
    @IBOutlet var tfName: UITextField!
    @IBOutlet var lPlace: UILabel!
    @IBOutlet var lSun: UILabel!
    @IBOutlet var lAddress: UILabel!
    @IBOutlet var tfAddress: UITextField!
    @IBOutlet var lCity: UILabel!
    @IBOutlet var tfCity: DataPickerTextField!
    @IBOutlet var vIndicatorLocation: UIActivityIndicatorView!
    @IBOutlet var vIndicatorValidate: UIActivityIndicatorView!
    @IBOutlet var vContainer: CornerRaduisV!
    @IBOutlet var vOrient: UIView!
    @IBOutlet var vPlace: UIView!
    
    var indexSun = 0
    var indexPlace = 0
    var indexOrient = 0
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tfCity.pickerViewDelegate = self

        self.tfCity.dataValues = pays.getPaysName()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tfPlace.pickerViewDelegate = self
        self.tfSun.pickerViewDelegate = self
        self.tfOrient.pickerViewDelegate = self
        
        self.tfPlace.pickerIdentifier = FormPickerType.Place
        self.tfSun.pickerIdentifier = FormPickerType.Sun
        self.tfOrient.pickerIdentifier = FormPickerType.Orientation
        
        self.tfPlace.dataValues = PlacesArray
        self.tfSun.dataValues = SunArray
        self.tfOrient.dataValues = OrientArray
        
        self.locationManager.delegate = self
        
        guard let gardener = ScannerService.shared.gardener else { return }
        if (gardener.type == "parcelle") {
            self.vPlace.isHidden = true
            self.vOrient.isHidden = false
        } else {
            self.vPlace.isHidden = false
            self.vOrient.isHidden = true
        }
    }
    
    fileprivate func setUnderline(_ tf: UITextField) {
        var bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: tf.frame.height, width: tf.frame.width, height: 1.0)
        bottomLine.backgroundColor = Styles.PlantRMainGreen.cgColor
        tf.borderStyle = UITextField.BorderStyle.none
        tf.layer.addSublayer(bottomLine)
    }
    
    @IBAction func localisationTapped(_ sender: Any) {
        if (CLLocationManager.locationServicesEnabled()) {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                let alertController = UIAlertController(title: NSLocalizedString("you_must_authorize_the_localization_of_the_agrove", comment: "you_must_authorize_the_localization_of_the_agrove"), message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("edit", comment: "edit"), style: .default, handler: { _ in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }))
                alertController.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: nil))
                alertController.view.tintColor = Styles.PlantRMainGreen
                self.present(alertController, animated: true, completion: nil)
                
            case .authorizedAlways, .authorizedWhenInUse :
                self.bLocation.isHidden = true
                self.vIndicatorLocation.startAnimating()
                locationManager.startUpdatingLocation()

            default:
                self.popOKAlertController(title: NSLocalizedString("an_error_occurred_while_retrieving_your_address", comment: "an_error_occurred_while_retrieving_your_address"))
            }
        } else {
            print("LOCALISATION false")
            self.popOKAlertController(title: NSLocalizedString("you_need_to_enable_location_in_order_to_retrieve_your_address", comment: "you_need_to_enable_location_in_order_to_retrieve_your_address"))
        }
    }
    
    @IBAction func ibBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func bValidate(_ sender: UIButton) {
        if (self.tfName.text?.trimmingLeadingAndTrailingSpaces().isEmpty == true) {
            self.popOKAlertController(title: NSLocalizedString("fill_in_all_the_information", comment: "fill_in_all_the_information"))
            return
        }

        sender.isEnabled = false
        guard var user = Auth.auth().currentUser, let name = self.tfName.text?.trimmingLeadingAndTrailingSpaces(), let address = self.tfAddress.text, let city = self.tfCity.text  else {
            self.popOKAlertController(title: NSLocalizedString("fill_in_all_the_information", comment: "fill_in_all_the_information"))
            sender.isEnabled = true
            return
        }
        guard let gardener = ScannerService.shared.gardener else {
            sender.isEnabled = true
            return
        }
        let dictMetadata = self.gardenerTransformer.toDictonary(GardenerMetadataModel(name: name, city: city, address: address, zipCode: self.tfAddress.text!, images: [:], emplacement: self.indexPlace, ensoleillement: self.indexSun, orientation: self.indexOrient, countryCode: self.pays.getCodeByName(name: self.tfCity.text!)))
        self.userRepository.getReference(for: user.uid).child("gardeners").child(gardener.id).removeValue()
        self.userRepository.getReference(for: user.uid).child("gardeners").child(gardener.id).setValue(true)
        self.userRepository.getCurrentGardenerReference(for: user.uid).setValue(gardener.id)
        self.gardenerRepository.getMetadataReference(for: gardener.id).setValue(dictMetadata, withCompletionBlock: { error, value in
            if (error == nil) {
                self.popOKAlertController(title: NSLocalizedString("vegetable_garden_added", comment: "vegetable_garden_added"), message: "", okHandler: { _ in
                    NotificationCenter.default.post(name: UserService.refreshGardenerNotification, object: nil)
                    self.dismiss(animated: true, completion: nil)
                })
            } else {
                self.popOKAlertController(title: NSLocalizedString("an_error_occurred_while_updating_the_data_of_the_planter", comment: "an_error_occurred_while_updating_the_data_of_the_planter"), message: "", okHandler: { _ in
                    self.dismiss(animated: true, completion: nil)
                })
            }
        })
/*        let gardenerModel = ClassicGardener(ispublic: false, stage: stage, metadata: GardenerMetadataModel(name: name, city: city, address: address, images: [:], emplacement: indexPlace, ensoleillement: indexSun), owners: [user.uid:true], type: type, dimension: dimension)
        self.gardenerRepository.getReference(for: scanService.id).observeSingleEvent(of: .value, with: { (snapGardener) in
            let gToEdit = self.gardenerTransformer.toGardenerModel(snap: snapGardener)
            let newGardenerModel = GardenerModel(id: gToEdit.id, metadata: GardenerMetadataModel(name: name, city: city, address: address, images: [:], emplacement: self.indexPlace, ensoleillement: self.indexSun), climat: gToEdit.climat, stats: gToEdit.stats, friends: gToEdit.friends, owner: gToEdit.owner, owners: gToEdit.owners, wishlist: gToEdit.wishlist, invitation: gToEdit.invitation, tips: gToEdit.tips, taskPlants: gToEdit.taskPlants, stage: stage, ispublic: false, subcribemember: gToEdit.subcribemember, type: type, dimension: dimension)
        })

        let classicGardenerDict = gardenerTransformer.toGardenerModel(snap: <#T##DataSnapshot#>)
        gardenerRepository.getReference(for: "Classic\(generateId)").setValue(classicGardenerDict, withCompletionBlock: { (result, error) in
            if (error == nil) {
                self.popOKAlertController(title: "Nouveau potager ajouté !", message: "", okHandler: {_ in
                    self.navigationController?.popViewController(animated: true)
                })
            }
            sender.isEnabled = true
        })//.setValue(classicGardenerDict)*/
    }
}

extension FormJumelageGardenerVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lat = locations.last?.coordinate.latitude, let long = locations.last?.coordinate.longitude {
            lookUpCurrentLocation { geoLoc in
                guard let localisation = geoLoc else { return }
                guard let locality = localisation.locality, let name = localisation.name else { return }
                self.tfAddress.text = name
                self.tfCity.text = locality
                self.vIndicatorLocation.stopAnimating()
                self.bLocation.isHidden = false
                self.locationManager.stopUpdatingLocation()
            }
        } else {
            self.vIndicatorLocation.stopAnimating()
            self.bLocation.isHidden = false
            self.locationManager.stopUpdatingLocation()
            return
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?) -> Void ) {
        if let lastLocation = self.locationManager.location {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(lastLocation, completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?.first
                    completionHandler(firstLocation)
                } else {
                    completionHandler(nil)
                }
            })
        } else {
            completionHandler(nil)
        }
    }
}
