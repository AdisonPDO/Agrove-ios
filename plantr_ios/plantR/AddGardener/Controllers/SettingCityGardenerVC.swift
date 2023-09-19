//
//  SettingCityGardenerVC.swift
//  plantR_ios
//
//  Created by Boris Roussel on 02/09/2020.
//  Copyright © 2020 Rabissoni. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class SettingCityGardenerVC: UIViewController, DataPickerTextFieldDelegate {
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
    
    var indexSun = 0
    var indexPlace = 0
    var indexOrient = 0
    

    @IBOutlet var addressGardernerTextField: UITextField!
    @IBOutlet var cityGardernerTextField: DataPickerTextField!
    @IBOutlet weak var requestLocationButton: UIButton!
    @IBOutlet weak var localityActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorFinish: UIActivityIndicatorView!
    @IBOutlet weak var finishButton: UIButton!
    

    let locationManager = CLLocationManager()
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!
    var currentGardener: String!
    private var currentUser: User!
    var gardenerName: String!
    var pays = PaysUtils()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cityGardernerTextField.pickerViewDelegate = self

        self.cityGardernerTextField.dataValues = pays.getPaysName()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        currentUser = Auth.auth().currentUser
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func requestLocationTapped(_ sender: UIButton) {

        if (CLLocationManager.locationServicesEnabled()) {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                let alertController = UIAlertController(title: NSLocalizedString("you_must_authorize_the_localization_of_the_agrove", comment: "You must authorize the localization of the Agrove application in order to retrieve your address."), message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("edit", comment: "edit"), style: .default, handler: { _ in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }))
                alertController.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: nil))
                alertController.view.tintColor = Styles.PlantRMainGreen
                self.present(alertController, animated: true, completion: nil)
                
            case .authorizedAlways, .authorizedWhenInUse :
                self.requestLocationButton.isHidden = true
                self.finishButton.isEnabled = false
                self.localityActivityIndicator.startAnimating()
                locationManager.startUpdatingLocation()

            default:
                self.popOKAlertController(title: NSLocalizedString("an_error_occurred_while_retrieving_your_address", comment: "An error occurred while retrieving your address."))
            }
        } else {
            print("LOCALISATION false")
            self.popOKAlertController(title: NSLocalizedString("you_need_to_enable_location_in_order_to_retrieve_your_address", comment: "You need to enable location in order to retrieve your address."))
        }
    }
    @IBAction func finishTapped(_ sender: UIButton) {
        sender.isEnabled = false
        self.activityIndicatorFinish.startAnimating()
        guard self.cityGardernerTextField.text! != "" && self.addressGardernerTextField.text! != "", var gardener = ScannerService.shared.gardener else {
            sender.isEnabled = true
            self.activityIndicatorFinish.stopAnimating()
            self.popOKAlertController(title: NSLocalizedString("put_a_city_address_to_your_planter", comment: "Put a city/address to your planter!"))
            return
        }
        let metadata = GardenerMetadataModel(name: gardenerName!, city: self.cityGardernerTextField.text!, address: self.addressGardernerTextField.text!, zipCode: self.addressGardernerTextField.text!, images: [:], emplacement: 0, ensoleillement: 0, orientation: 0, countryCode: self.pays.getCodeByName(name: self.cityGardernerTextField.text!))
        let dictToOwnerGardenerFireBase = self.gardenerTransformer.toDictonary(metadata)
        let newGardenerReference = self.gardenerRepository.getMetadataReference(for: gardener.id)
        newGardenerReference.setValue(dictToOwnerGardenerFireBase) { (error, _) in
            if let error = error {
                sender.isEnabled = true
                print(error)
                self.activityIndicatorFinish.stopAnimating()
                self.popOKAlertController(title: NSLocalizedString("an_error_has_occurred", comment: "An error has occurred!"))
            } else {
                self.popOKAlertController(title: NSLocalizedString("your_planter_is_fully_configured", comment: "Your planter is fully configured!"), message: "", okHandler: { _ in
                    UserService.shared.splashFirstLoad = false
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
    }
}

extension SettingCityGardenerVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
        
    }
}

extension SettingCityGardenerVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lat = locations.last?.coordinate.latitude, let long = locations.last?.coordinate.longitude {
            lookUpCurrentLocation { geoLoc in
                guard let localisation = geoLoc else { return }
                guard let locality = localisation.locality, let name = localisation.name else { return }
                self.addressGardernerTextField.text = name
                self.cityGardernerTextField.text = locality
                self.localityActivityIndicator.stopAnimating()
                self.finishButton.isEnabled = true
                self.requestLocationButton.isHidden = false
                self.locationManager.stopUpdatingLocation()
            }
        } else {
            self.localityActivityIndicator.stopAnimating()
            self.finishButton.isEnabled = true
            self.requestLocationButton.isHidden = false
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
                    self.finishButton.isEnabled = true
                    completionHandler(nil)
                }
            })
        } else {
            self.finishButton.isEnabled = true
            completionHandler(nil)
        }
    }
}
