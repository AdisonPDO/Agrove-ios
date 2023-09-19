//
//  ConnexionBluetoothVC.swift
//  plantR_ios
//
//  Created by Rabissoni on 18/01/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit
import CoreBluetooth
import Firebase

class ConnexionBluetoothVC: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scanButton: UIButton!
    
    var bleSettings: BLESettings!
    var userRepository: UserRepository!
    var userTransformer: UserTransformer!
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!
    
    private var peripherals: CBPeripheral!
    private var statusBLE: CBManagerState!
    private var gardenerID: String!
    private var bleTimer: Timer!
    
    var wifiName: String!
    var passwordName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bleSettings.delegate = self
        bleSettings.wifiName = wifiName
        bleSettings.password = passwordName
        bleSettings.owner = Auth.auth().currentUser?.uid  
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        bleSettings.stopScan()
        if peripherals != nil {
            bleSettings.disconnect(peripherals!)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
/*        if segue.identifier == StoryboardSegue.AddGardener.goToNameGardener.rawValue {
            let vc = segue.destination as! SettingNameGardenerVC
            vc.currentGardener = self.gardenerID
        }*/
    }
    
    @IBAction func settingBluetoothTaped(_ sender: Any) {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func scanTapped(_ sender: Any) {

//         self.perform(segue: StoryboardSegue.AddGardener.goToNameGardener, sender: "123)
        
        if statusBLE == .poweredOn {
            scanButton.isEnabled = false
            self.activityIndicator.startAnimating()
            bleTimer = Timer.scheduledTimer(withTimeInterval: 45, repeats: false, block: { [ weak self ]( _ ) in
                guard let self = self else { return }
                self.bleSettings.stopScan()
                self.popOKAlertController(title: "Temps expiré! Veuillez relancer la procédure.")
                self.activityIndicator.stopAnimating()
                self.scanButton.isEnabled = true
            })
            bleSettings.startScan()
        } else {
            self.popOKAlertController(title: "Le bluetooth n'est pas activé.")
        }
    }
}

extension ConnexionBluetoothVC: BLESettingsDelegate {
    
    func didFindGardenerID(gardenerID: String) {
        bleTimer.invalidate()
        self.gardenerID = gardenerID
        self.activityIndicator.stopAnimating()
        self.scanButton.isEnabled = true
        self.bleSettings.disconnect(self.peripherals)
        switch self.gardenerID {
        case ErrorPairing.Bluetooth:
            self.popOKAlertController(title: "Mince un problème de connexion Bluetooth, veuillez relancer la procédure.")
        case ErrorPairing.Wifi:
            self.popOKAlertController(title: "Vérifier que le nom du Wi-Fi et le mot de passe sont corrects. Veuillez relancer la procédure!")
        default:
            if self.gardenerID != nil {
                let reference = self.gardenerRepository.getReference(for: self.gardenerID!)
                reference.observe(.value, with: { snap in
                    let gardener = self.gardenerTransformer.toGardenerModel(snap: snap)
                    if Auth.auth().currentUser?.uid == gardener.owner {
                        self.userRepository.getCurrentGardenerReference(for: Auth.auth().currentUser!.uid).setValue(self.gardenerID!) { (error, _) in
                            if let error = error {
                                print(error)
                                self.popOKAlertController(title: "Une erreur est survenue !")
                            } else {
/*                                self.perform(segue: StoryboardSegue.AddGardener.goToNameGardener, sender: self.gardenerID)*/
                            }
                        }
                    }
                })
            }
        }
    }
    
    func didStatusBLE
        (status: CBManagerState) {
        self.statusBLE = status
    }
    
    func didConnectToHardware(peripheral: CBPeripheral) {
        self.peripherals = peripheral
    }
}
