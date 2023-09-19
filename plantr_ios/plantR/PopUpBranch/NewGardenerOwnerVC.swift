//
//  NewGardenerOwner.swift
//  plantR_ios
//
//  Created by Boris Roussel on 01/09/2020.
//  Copyright © 2020 Rabissoni. All rights reserved.
//

import UIKit
import Firebase

class NewGardenerOwnerVC: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!

    private var handleAddToOwners: UInt?
    private var userAddToOwnersRef: DatabaseReference?

    var userRepository: UserRepository!
    var userTransformer: UserTransformer!
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard var user = Auth.auth().currentUser else {
            UserService.shared.splashFirstLoad = false
            self.dismiss(animated: true, completion: nil)
            return
        }
        checkFromBranch(user.uid)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        UserService.shared.splashFirstLoad = false
        self.userAddToOwnersRef?.removeValue()
        if let handleAddToOwner = handleAddToOwners {
            self.userAddToOwnersRef?.removeObserver(withHandle: handleAddToOwner)
        }
    }
    
    
    @IBAction func backTapped(_ sender: UIButton) {
        UserService.shared.splashFirstLoad = false
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func checkFromBranch(_ userId: String) {
        if (BranchService.shared.branchGoToOwner) {
            guard var gardenerId = BranchService.shared.branchId, var gardenerName = BranchService.shared.gardenerName else { return }
            self.userAddToOwnersRef = self.userRepository.getMetadataAddToOwnersReference(for: userId)
            self.handleAddToOwners = self.userAddToOwnersRef?.observe(.value, with: { (snapResult) in
                let result = snapResult.value as? String
                switch result {
                case "ok":
                    BranchService.shared.reset()
                    self.userAddToOwnersRef?.removeValue()
                    self.activityIndicator.stopAnimating()
                    self.titleLabel.text = NSLocalizedString("you_have_joined_the_gardening_team", comment: "You have joined the gardening team!")
                    self.contentLabel.text = "\(gardenerName)"
                    self.titleLabel.isHidden = false
                    self.contentLabel.isHidden = false
                    self.backButton.isHidden = false
                    gardenerId.removeFirst()
                    gardenerId.removeFirst()
                    print("GARDENER ID SETVALUE => \(gardenerId)")
                    self.userRepository.getCurrentGardenerReference(for: userId).setValue(gardenerId)
                    self.userRepository.getReference(for: userId).child("gardenersGuest").child(gardenerId).removeValue()
                    break;
                case "ko":
                    BranchService.shared.reset()
                    self.userAddToOwnersRef?.removeValue()
                    self.activityIndicator.stopAnimating()
                    self.titleLabel.text = NSLocalizedString("you_have_encountered_a_problem_when_adding_to_the_team", comment: "ou have encountered a problem when adding to the team")
                    self.contentLabel.text = "\(gardenerName)"
                    gardenerId.removeFirst()
                    gardenerId.removeFirst()
                    self.userRepository.getCurrentGardenerReference(for: userId).setValue(gardenerId)
                    self.userRepository.getReference(for: userId).child("gardenersGuest").child(gardenerId).removeValue()
                    self.backButton.isHidden = false
                    self.titleLabel.isHidden = false
                    self.contentLabel.isHidden = false
                    break;
                default:
                    self.backButton.isHidden = false
                    break;
                }
            })
            self.userRepository.getMetadataAddToOwnersReference(for: userId).setValue(gardenerId)
            BranchService.shared.reset()
        }
        if (BranchService.shared.branchGoToGuest) {
            BranchService.shared.reset()
            guard var gardenerId = BranchService.shared.branchId else { return }

        }
    }
}
