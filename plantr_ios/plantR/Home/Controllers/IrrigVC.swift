//
//  IrrigVC.swift
//  plantR_ios
//
//  Created by Adison Pereira de oliveira on 18/05/2022.
//  Copyright © 2022 Agrove. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseUI

class IrrigVC : UIViewController{
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var irrigTextField: UITextField!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var butt: UIButton!
    
    private var handleCurrentGardener: UInt?
    private var currentUser: User!
    private var userCurrentGardenerRef: DatabaseReference!
    var userRepository: UserRepository!
    var userTransformer: UserTransformer!
    private var currentGardener: String!
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!
    var gardenerModel: GardenerModel?
    var date = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentUser = Auth.auth().currentUser

        self.userCurrentGardenerRef = self.userRepository.getCurrentGardenerReference(for: currentUser.uid)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.handleCurrentGardener = self.userCurrentGardenerRef.observe(.value, with: { (snapshot) in
            self.currentGardener = snapshot.value as? String
            if self.currentGardener.isEmpty {
                NotificationCenter.default.post(name: UserService.visitedUserNotification, object: nil)
            } else {
                self.gardenerRepository.getReference(for: self.currentGardener).observeSingleEvent(of: .value, with: { (snapGardener) in
                    var gardener = self.gardenerTransformer.toGardenerModel(snap: snapGardener)
                    
                    var irrig = gardener.irrigation.received.request.value.data.components(separatedBy: ",")
                    if(gardener.irrigation.received.updated != ""){
                        self.date = convertStringToDate(dateString: gardener.irrigation.received.updated)
                    }
                    if(irrig.count > 4){
                        self.irrigTextField.text = String(irrig[4])
                    }
                    self.setText(state: gardener.irrigation.received.status)
                })
            }
    })
}
    @IBAction func buttTapped(_ sender: Any) {
        let irrigVal = Int(self.irrigTextField.text ?? "") ?? 12

        // Check irrigation value beceause only number was required
        if(irrigVal != nil){
            if(irrigVal < 1 || irrigVal > 100){
                //TODO: print error we need value between 1 and 100
            }else{
                //TODO: send data
                if let currentGardener = self.currentGardener  {
                    let realIrig = irrigVal
                    self.gardenerRepository.getGardenerIrrigationRef(by: String(self.currentGardener)).child("payload").setValue("61;135;138,0,0,1;130,\(String(realIrig)),0,15;14,0,0,0,1;138;134;", withCompletionBlock: {(error, irrig) in
                    })
                    self.gardenerRepository.getGardenerIrrigationRef(by: String(self.currentGardener)).child("received").child("request").child("value").child("data").setValue("61;135;138,0,0,1;130,\(String(realIrig)),0,15;14,0,0,0,1;138;134;", withCompletionBlock: {(error, irrig) in
                    })
                    self.gardenerRepository.getGardenerIrrigationRef(by: String(self.currentGardener)).child("received").child("status").setValue("PENDING", withCompletionBlock: {(error, irrig) in
                    })
                } else {
                    print("nonononono + \(self.currentGardener)")
                }
            }
        }else{
            //TODO: print error only number was accepted
        }
        
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func quitTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)

        dismiss(animated: true, completion: nil)
    }
    
    private func setText(state: String){
        if(state == "CANCELED" || state == "ERROR"){
            self.descriptionLabel.text = NSLocalizedString("irrig_msg4", comment: "irrig_msg4")
            self.butt.setTitle(NSLocalizedString("define", comment: "define"), for: .normal)
            self.titleLabel.text = NSLocalizedString("irrig_msg3", comment: "irrig_msg3")
        }else if(state != "PENDING"){
            self.descriptionLabel.text = NSLocalizedString("irrig_msg1", comment: "irrig_msg1")
            self.butt.setTitle(NSLocalizedString("define", comment: "define"), for: .normal)
            self.titleLabel.text = NSLocalizedString("text_seuil", comment: "text_seuil")
        }else {
            self.descriptionLabel.text = NSLocalizedString("irrig_msg2", comment: "irrig_msg2")
            self.butt.setTitle(NSLocalizedString("ok", comment: "ok"), for: .normal)
            self.titleLabel.text = "\(NSLocalizedString("text_parameters", comment: "text_parameters"))\(self.date)"
            self.irrigTextField.isUserInteractionEnabled = false
        }
    }
}
