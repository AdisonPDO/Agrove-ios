//
//  AddToFollowVC.swift
//  plantR_ios
//
//  Created by Boris Roussel on 26/08/2020.
//  Copyright © 2020 Rabissoni. All rights reserved.
//

import Firebase
import UIKit

class AddToFollowVC: UIViewController {

    var dismissDelegate: DismissDelegate?
    @IBOutlet weak var gardenerName: UILabel!
    @IBOutlet weak var gardenerImage: UIImageView!

    @IBOutlet var quitButt: UIButton!
    @IBOutlet weak var askToBeMemberButton: UIButton!
    var userRepository: UserRepository!
    var userTransformer: UserTransformer!
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!

    var currentUser: User!
    var followGardener: GardenerModel!
    @IBOutlet var msgLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.quitButt.setTitle(NSLocalizedString("no_thanks", comment: "no_thanks"), for: .normal)
        
        currentUser = Auth.auth().currentUser
        print("GARDENER ADD TO FOLLOW")
        followGardener = ScannerService.shared.gardener
        guard followGardener != nil else {
            print("GUARD VIEWDIDLOAD")
            ScannerService.shared.reset()
            self.dismiss(animated: true, completion: nil)
            return
        }
        gardenerName.text = followGardener.metadata.name
        if (followGardener.metadata.images.count > 0) {
            let firstPicture: String = followGardener.metadata.images.keys.first ?? ""
            print(followGardener.id)
            print(firstPicture)
            let imageStorage = gardenerRepository.getGardenerImage(by: followGardener.id, name: "\(firstPicture).jpg")
            gardenerImage.sd_setImage(with: imageStorage)
        } else {
        }
        if (followGardener.ispublic) {
            self.askToBeMemberButton.isHidden = false
        } else {
            self.askToBeMemberButton.isHidden = true
            self.quitButt.isHidden = true
            self.msgLabel.text = NSLocalizedString("is_lock_msg", comment: "is_lock_msg")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
           self.dismissDelegate?.didDismiss()
    }
    
    @IBAction func dismissTapped(_ sender: UIButton) {
        ScannerService.shared.reset()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func followGardener(_ sender: UIButton) {
        sender.isEnabled = false
        
        self.userRepository.getGardenerGuestReference(for: currentUser.uid).child(followGardener.id).setValue(true) { _,_  in
            ScannerService.shared.showGoToSubscribe = true
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func askToBeMember(_ sender: UIButton) {
        self.gardenerRepository.getGardenerSubscribeMemberWithIdReference(by: followGardener.id, userId: currentUser.uid).setValue(true, withCompletionBlock: { error, ref in
            if error == nil {
                self.popOKAlertController(title: NSLocalizedString("the_request_to_be_added_to_the_team_sent", comment: "The request to be added to the team sent"), message: "", okHandler: { _ in
                    self.dismiss(animated: true, completion: nil)
                })
            } else {
                self.popOKAlertController(title: NSLocalizedString("an_error_has_occurred", comment: "An error has occurred!"), message: "", okHandler: { _ in
                    self.dismiss(animated: true, completion: nil)
                })
            }
        })
    }
    
}
