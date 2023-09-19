//
//  MyTeamVC.swift
//  plantR_ios
//
//  Created by Boris Roussel on 31/08/2020.
//  Copyright © 2020 Rabissoni. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import MessageUI
import CoreLocation
import Branch

class MyTeamVC: UIViewController {

    var userRepository: UserRepository!
    var userTransformer: UserTransformer!
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!
    
    private var currentUser: User!
    private var gardenerModel: GardenerModel?
    private var currentGardener: String!
    var dataSource: FUICollectionViewDataSource!

    private var gardernerRef: DatabaseReference!
    private var userRef: DatabaseReference!
    private var owners: [String] = ["ADD_OWNER"]
    
    private var handleGardener: UInt?
    private var handleUser: UInt?
    
    @IBOutlet var infosButton: UIButton!
    @IBOutlet weak var subscribeMemberButton: UIButton!
   
    @IBOutlet var infosView: UIView!
    
    
    @IBOutlet weak var subMemberAlert: CIRoundedImageView!
    @IBOutlet weak var teamCV: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentUser = Auth.auth().currentUser
        self.userRef = self.userRepository.getReference(for: self.currentUser.uid)
    }
    

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let handleUser = handleUser {
            userRef.removeObserver(withHandle: handleUser)
        }
        if let handleGardener = handleGardener {
            gardernerRef.removeObserver(withHandle: handleGardener)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.handleUser = self.userRef.observe(.value, with: { snap in
            let user = self.userTransformer.toUserModel(snap: snap)
            self.gardernerRef = self.gardenerRepository.getReference(for: user.currentGardener)
            self.currentGardener = user.currentGardener
            self.handleGardener = self.gardernerRef.observe(.value, with: { snap in
                let gm = self.gardenerTransformer.toGardenerModel(snap: snap)
                self.gardenerModel = gm
                if(gm.type == "pot" || gm.type == "jardiniere" || gm.type == "carre" ){
                    self.subscribeMemberButton.isHidden = true
                    //self.closeOpenButton.isHidden = true
                }else{
                    self.subscribeMemberButton.isHidden = false
                    //self.closeOpenButton.isHidden = false
                }

                if (gm.ispublic) {
                    if let image = UIImage(named: "cadenas_fermer.png") {
                        //self.closeOpenButton.setImage(image, for: .normal)
                    }
                } else {
                    if let image = UIImage(named: "cadenas_ouvert.png") {
                        //self.closeOpenButton.setImage(image, for: .normal)
                    }
                }
                if (gm.subcribemember.isEmpty) {
                    self.subMemberAlert.isHidden = true
                } else {
                    self.subMemberAlert.isHidden = false
                }
                let ownersData = self.gardenerTransformer.toOwnersModel(gm.owners)
                self.owners = ["ADD_OWNER"]
                ownersData.forEach { ownerId in
                    if (ownerId != user.id) {
                        self.owners.append(ownerId)
                    }
                }
                self.teamCV.reloadData()
            })
        })
    }
    
    @IBAction func membersTapped(_ sender: UIButton) {
        if let gardenerModel = self.gardenerModel {
            let controller = StoryboardScene.MyTeam.subscribeMemberTeamCV.instantiate()
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .overFullScreen
            controller.gardenerId = gardenerModel.id
            controller.currentUser = self.currentUser
            controller.gardenerModel = self.gardenerModel
            controller.currentGardener = self.currentGardener
            controller.gardernerRef = self.gardernerRef
            controller.userRef = self.userRef
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func infoTapped(_ sender: Any) {
                let controller = StoryboardScene.MyTeam.myTeamAlertVC.instantiate()
                controller.modalTransitionStyle = .crossDissolve
                controller.modalPresentationStyle = .overFullScreen
                PopAlertServices().pop(view: self, str: "response_info_my_team", title: "why_constitue_team", isDismiss: false)
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension MyTeamVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.infosView.isHidden = self.owners.count > 1
        self.infosButton.isHidden = self.owners.count <= 1
        return self.owners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddTeam", for: indexPath) as! AddTeamCVC
            cell.delegate = self
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TeamCell", for: indexPath) as! TeamCellCVC
            cell.uid = self.owners[indexPath.row]
            cell.delegate = self
            let imageStorageImage = self.userRepository.getImageProfile(for: cell.uid)
            cell.imageProfil.sd_setImage(with: imageStorageImage, placeholderImage: Asset.placeholderProfil.image)
            self.userRepository.getMetadataReference(for: cell.uid).observeSingleEvent(of: .value, with: { snap in
                guard let metaDict = snap.value as? [String: Any] else {
                    cell.name.text = ""
                    return }
                var metadata = self.userTransformer.toUserMetadataModel(metaDict)
                cell.name.text = "\(metadata.firstName) \(metadata.lastName)"
            })
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

extension MyTeamVC: TeamCVCellDelegate {
    func didDeleteOwnerButton(userId: String) {
        let alerteActionSheet = UIAlertController(title: NSLocalizedString("would_you_like_to_remove_this_person_from_your_team", comment: "would_you_like_to_remove_this_person_from_your_team"), message: NSLocalizedString("by_removing_this_person_from_the_team,_they_will_no_longer_have_access_to_the_planter", comment: "by_removing_this_person_from_the_team,_they_will_no_longer_have_access_to_the_planter"), preferredStyle: .alert)
        alerteActionSheet.view.tintColor = Styles.PlantRBlackColor
        let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: nil)
        let camera = UIAlertAction(title: NSLocalizedString("confirm", comment: "confirm"), style: .default) { _ in
            self.gardenerRepository.getGardenersOwnersRef(by: self.currentGardener).child(userId).removeValue()
        }
        alerteActionSheet.addAction(camera)
        alerteActionSheet.addAction(cancel)
        
        present(alerteActionSheet, animated: true, completion: nil)

    }
}

extension MyTeamVC: AddTeamCVCDelegate {
    func didAddButton() {
        print("ADD")
        guard let gardener = self.gardenerModel else { return }

        let buo = BranchUniversalObject.init(canonicalIdentifier: "InviteOwner")
        
        buo.title = NSLocalizedString("invitation_to_the_team", comment: "invitation_to_the_team")
        buo.contentDescription = "\(NSLocalizedString("you_are_invited_to_join_the_gardening_team", comment: "you_are_invited_to_join_the_gardening_team")) \(gardener.metadata.name) !"
        buo.contentMetadata.customMetadata["gardenerId"] = "\(gardener.stage)|\(gardener.id)"
        buo.contentMetadata.customMetadata["type"] = "goToOwner"
        buo.contentMetadata.customMetadata["name"] = gardener.metadata.name

        let lp = BranchLinkProperties()
        
        buo.showShareSheet(with: lp, andShareText: "\(NSLocalizedString("you_are_invited_to_join_the_gardening_team", comment: "you_are_invited_to_join_the_gardening_team")) \(gardener.metadata.name) !", from: self) { (activityType, completed) in
            if (completed == true) {
                self.popOKAlertController(title: NSLocalizedString("the_link_has_been_shared", comment: "the_link_has_been_shared"))
            }
        }
    }
}
