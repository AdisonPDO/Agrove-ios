//
//  SubscribeMemberTeamVC.swift
//  plantR_ios
//
//  Created by Boris Roussel on 05/02/2021.
//  Copyright © 2021 Agrove. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI


class SubscribeMemberTeamCV: UIViewController {
    
    @IBOutlet weak var tvSubscribeMembers: UITableView!
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!
    var userRepository: UserRepository!
    var userTransformer: UserTransformer!
    
    var gardernerRef: DatabaseReference!
    var userRef: DatabaseReference!
    @IBOutlet var privateSwitch: UISwitch!
    @IBOutlet var infosButton: UIButton!
    
    private var allUserSubscribe: DatabaseReference!
    private var handleallUserSubscribe: UInt?
    private var handleUser: UInt?
    
    var currentUser: User!
    var gardenerModel: GardenerModel?
    var currentGardener: String!
    
    var gardenerId = ""
    
    var allSubscribeMember: [UserModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.allUserSubscribe = self.gardenerRepository.getGardenerSubscribeMemberReference(by: gardenerId)
        self.tvSubscribeMembers.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.handleallUserSubscribe = self.allUserSubscribe.observe(.value, with: { (snapshot) in
            let subscribes = snapshot.value as? [String: Any] ?? [:]
            self.allSubscribeMember = []
            print("* RECYCLE HERE *")
            if (subscribes.isEmpty) {
                self.tvSubscribeMembers.reloadData()
            } else {
                subscribes.forEach({ item in
                    var key = item.key
                    self.userRepository.getReference(for: item.key).observeSingleEvent(of: .value, with: { (snapUser) in
                        
                        var user = self.userTransformer.toUserModel(snap: snapUser)
                        self.allSubscribeMember.append(user)
                        self.tvSubscribeMembers.reloadData()
                    })
                })
            }
        })
        self.privateSwitch.isOn = self.gardenerModel?.ispublic ?? false
        self.privateSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func infosTapped(_ sender: Any) {
        let controller = StoryboardScene.MyTeam.myTeamAlertVC.instantiate()
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        //self.present(controller, animated: true, completion: nil)
        self.popOKAlertController(title: NSLocalizedString("team_request_ask_title", comment: "team_request_ask_title"), message: NSLocalizedString("team_request_ask_desc", comment: "team_request_ask_desc"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func switchChanged(mySwitch: UISwitch) {
        let value = mySwitch.isOn
        if let gardenerModel = self.gardenerModel  {
            self.gardenerRepository.getGardenerIsPublicReference(by: gardenerModel.id).setValue(value, withCompletionBlock: { (error, ispublic) in
                if (error == nil) {
                    if (!value) {
                        self.popOKAlertController(title: NSLocalizedString("people_cant_join_your_team_anymore", comment: "people_cant_join_your_team_anymore"))
                    } else {
                        self.popOKAlertController(title: NSLocalizedString("people_can_now_join_your_team", comment: "people_can_now_join_your_team"))
                    }
                } else {
                    self.popOKAlertController(title: NSLocalizedString("an_error_has_occurred", comment: "an_error_has_occurred"))
                }
            })
        } else {
        }
    }
}

extension SubscribeMemberTeamCV: UITableViewDataSource, UITableViewDelegate, SubscribeMemberCellDelegate {
    
    func didDeleteSubscribeButton(userId: String, name: String) {
        let alertController = UIAlertController(title: NSLocalizedString("are_you_sure_you_don't_want_to_withdraw_the_application_to_join", comment: "are_you_sure_you_don't_want_to_withdraw_the_application_to_join"), message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: nil)
        alertController.addAction(cancel)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("remove", comment: "remove"), style: .default, handler: { _ in
            self.gardenerRepository.getGardenerSubscribeMemberWithIdReference(by: self.gardenerId, userId: userId).removeValue(completionBlock: { error, ref in
                if error == nil {
                    self.popOKAlertController(title: "\(name) \(NSLocalizedString("has_been_removed", comment: "has_been_removed"))")
                } else {
                    self.popOKAlertController(title: NSLocalizedString("an_error_has_occurred", comment: "an_error_has_occurred"))
                }
            })
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0//Choose your custom row height
    } 
    
    func didAddSubscribeButton(userId: String, name: String) {
        self.gardenerRepository.getGardenersOwnersRef(by: gardenerId).child(userId).setValue(true, withCompletionBlock: { error, ref in
            if (error == nil) {
                self.gardenerRepository.getReference(for: self.gardenerId).child("addToOwnersSubscribe").child(userId).setValue(true)
                let sender = PushNotificationSender()
                sender.sendPushNotification(to: self.gardenerId, title: NSLocalizedString("new_in_the_team", comment: "new_in_the_team"), body: "\(name) \(NSLocalizedString("joined_the_team", comment: "joined_the_team"))", userId: "")
                self.gardenerRepository.getGardenerSubscribeMemberWithIdReference(by: self.gardenerId, userId: userId).removeValue()
            } else {
                self.popOKAlertController(title: NSLocalizedString("an_error_has_occurred", comment: "an_error_has_occurred"))
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.allSubscribeMember.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subscribeMemberCell", for: indexPath) as! SubscribeMemberCell
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = bgColorView
        
        var user = self.allSubscribeMember[indexPath.row]
        let userProfileImage = self.userRepository.getImageProfile(for: user.id)
        
        cell.uid = user.id
        cell.delegate = self
        cell.ivUser.sd_setImage(with: userProfileImage,placeholderImage: Asset.placeholderProfil.image)
        cell.nameLabel.text = "\(user.metadata.firstName) \(user.metadata.lastName)"
        
        return cell
    }
    
}

