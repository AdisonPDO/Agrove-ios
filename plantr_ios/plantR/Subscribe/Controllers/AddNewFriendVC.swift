//
//  addNewFriendVC.swift
//  plantR_ios
//
//  Created by Rabissoni on 13/02/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit
import Firebase

class AddNewFriendVC: UIViewController {

    @IBOutlet var inviteCodeLabel: UITextField!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var rejoinButton: UIButton!
    
    private var currentUser: User!
    private var userInvitedRef: DatabaseReference!
    
    private var handleInvitedUser: UInt?
    
    var userRepository: UserRepository!
    var userTransformer: UserTransformer!
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.currentUser = Auth.auth().currentUser
        self.userInvitedRef = userRepository.getMetadataInvitedReference(for: currentUser.uid)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.handleInvitedUser = self.userInvitedRef.observe(.childAdded, with: { (snapInvited) in
            let result = snapInvited.value as! String
            self.userInvitedRef.removeValue()
            self.activityIndicator.stopAnimating()
            self.rejoinButton.isEnabled = true
            guard result == "ok" else {
                self.popOKAlertController(title: NSLocalizedString("wrong_validation_code", comment: "wrong_validation_code"))
                return
            }
            self.popOKAlertController(title: NSLocalizedString("validation_code_validated", comment: "validation_code_validated"), message: nil, okHandler: { _ in
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            })

        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let handleInvitedUser = handleInvitedUser {
            self.userInvitedRef.removeObserver(withHandle: handleInvitedUser)
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addInviteCode(_ sender: UIButton) {
        self.rejoinButton.isEnabled = false
        self.activityIndicator.startAnimating()
        guard self.inviteCodeLabel.text != "", let code = self.inviteCodeLabel.text else {
            self.popOKAlertController(title: NSLocalizedString("please_enter_an_invitation_codep", comment: "please_enter_an_invitation_codep"))
            return
        }
        self.userInvitedRef.setValue(code)
    }
}
