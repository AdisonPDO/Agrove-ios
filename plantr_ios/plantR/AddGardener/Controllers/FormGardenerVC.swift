//
//  FormGardenerVC.swift
//  plantR_ios
//
//  Created by Boris Roussel on 01/06/2021.
//  Copyright © 2021 Agrove. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseUI
import FirebaseAuth

class FormGardenerVC: UIViewController, DataPickerTextFieldDelegate {
    
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!
    var userRepository: UserRepository!
    var userTransformer: UserTransformer!
    
    func didSelectRow(pickerView: UIPickerView, row: Int, component: Int, identifier: String, value: String) {
        if identifier == FormPickerType.Sun {
            indexSun = row
        }
        if identifier == FormPickerType.Place {
            indexPlace = row
        }
        if (identifier == FormPickerType.Orientation) {
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
    @IBOutlet var vPlace: UIView!
    @IBOutlet var vOrient: UIView!
    var pays = PaysUtils()
    
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
                let alertController = UIAlertController(title: NSLocalizedString("you_must_authorize_the_localization_of_the_agrove", comment: "permission"), message: nil, preferredStyle: .alert)
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
                self.popOKAlertController(title: NSLocalizedString("an_error_occurred_while_retrieving_your_address", comment: "alert"))
            }
        } else {
            print("LOCALISATION false")
            self.popOKAlertController(title: NSLocalizedString("you_need_to_enable_location_in_order_to_retrieve_your_address", comment: "alert"))
        }
    }
    
    @IBAction func ibBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func bValidate(_ sender: UIButton) {
        if self.tfName.text?.trimmingLeadingAndTrailingSpaces().isEmpty == true {
            self.popOKAlertController(title: NSLocalizedString("fill_in_all_the_information", comment: "fill in all the information"))
            return
        }
        sender.isEnabled = false
        let type = AddGardenerService.shared.getType()
        let dimension = AddGardenerService.shared.getDimension()
        let generateId = gardenerRepository.getRootReference().childByAutoId()
        
        guard let user = Auth.auth().currentUser, let name = self.tfName.text?.trimmingLeadingAndTrailingSpaces(), let address = self.tfAddress.text, let city = self.tfCity.text, let dimension = dimension, let type = type, let generateId = generateId.key else {
            self.popOKAlertController(title: NSLocalizedString("fill_in_all_the_information", comment: "fill in all the information"))
            sender.isEnabled = true
            return
        }
        
        let stage = AddGardenerService.shared.getStage(dimension)
        guard let stage = stage else {
            sender.isEnabled = true
            return
        }
        
        let gardenerModel = ClassicGardener(ispublic: false, stage: stage, metadata: GardenerMetadataModel(name: name, city: "", address: "", zipCode: address, images: [:], emplacement: indexPlace, ensoleillement: indexSun, orientation: indexOrient, countryCode: self.pays.getCodeByName(name: city)), owners: [user.uid:true], type: type, dimension: dimension)
        
        let classicGardenerDict = gardenerTransformer.toGardenerClassic(gardenerModel)
        print("aaaaaaaaaaaaaaaaaaaaaaa \(gardenerModel)")
        self.userRepository.getReference(for: user.uid).observeSingleEvent(of: .value, with: { snapUser in
            let userModel = self.userTransformer.toUserModel(snap: snapUser)
            let realGardenerId = "Classic\(generateId)"
            var arrGardeners: [String:Bool] = [:]

            userModel.gardeners.forEach { arrGardeners[$0] = true }
            arrGardeners[realGardenerId] = true

            self.gardenerRepository.getReference(for: realGardenerId).setValue(classicGardenerDict, withCompletionBlock: { (error, result) in
                if (error == nil) {
                    self.userRepository.getReference(for: user.uid).child("gardeners").setValue(arrGardeners)
                    self.userRepository.getCurrentGardenerReference(for: user.uid).setValue(realGardenerId)
                    self.popOKAlertController(title: NSLocalizedString("vegetable_garden_added", comment: "vegetable garden added"), message: "", okHandler: {_ in
                        NotificationCenter.default.post(name: UserService.refreshGardenerNotification, object: nil)
                        self.dismiss(animated: true, completion: nil)
                    })
                } else {
                    self.popOKAlertController(title: NSLocalizedString("a_problem_occurred", comment: "a problem occurred"), message: "", okHandler: {_ in
                        self.dismiss(animated: true, completion: nil)
                    })
                }
                sender.isEnabled = true
            })//.setValue(classicGardenerDict)
        })
    }
}

extension FormGardenerVC: CLLocationManagerDelegate {
    
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
