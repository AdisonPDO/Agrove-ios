//
//  FriendsVC.swift
//  plantR_ios
//
//  Created by Rabissoni on 06/02/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class SubscribeVC: UIViewController {

    @IBOutlet weak var activityIndicatorImageRandom: UIActivityIndicatorView!
    @IBOutlet var nameGardener: UILabel!
    @IBOutlet var imageRandom: UIImageView!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var collectionViewFriends: UICollectionView!
    @IBOutlet var iconUserProfile: CIRoundedImageView!
    @IBOutlet var zoneBlurFriend: UIImageView!

    var userRepository: UserRepository!
    var userTransformer: UserTransformer!
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!

    var dataSource: FUICollectionViewDataSource!

    private var userRef: DatabaseReference!

    private var currentUser: User!

    private var handleUser: UInt!

    private var friendsCache: [String: DataSnapshot] = [:]

    private var dictGardenersPic: [String: FriendImages] = [:]
    private var allImageGardener: [ImagesGardener] = []
    private var timer: Timer?

    private var gardenersGuestRef: DatabaseReference!
    private var gardenerList: [String] = []
    private var gardenerListModels: [GardenerModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.currentUser = Auth.auth().currentUser
        self.userRef = self.userRepository.getReference(for: self.currentUser.uid)
    }


    
    private func setGardenerProperty(_ cell: FriendsCVCell, gardenerModel: GardenerModel) {
        var images = gardenerModel.metadata.images.map { $0.key}
        if images.count > 0 {
            if images.contains("logo") {
                cell.profileImageView.contentMode = .scaleAspectFill
                cell.profileImageView.sd_setImage(with: self.gardenerRepository.getGardenerImage(by: gardenerModel.id, name: "logo.jpg"))
            } else {
                cell.profileImageView.contentMode = .scaleAspectFill
                cell.profileImageView.sd_setImage(with: self.gardenerRepository.getGardenerImage(by: gardenerModel.id, name: "\(images.first!).jpg"))
            }
        } else {
            cell.profileImageView.contentMode = .center
            cell.profileImageView.image = UIImage.init(named: "iconeMesPlantes")
        }
        cell.userNameLabel.text = gardenerModel.metadata.name
        cell.delegate = self
        cell.gardenerId = gardenerModel.id
        cell.deletedButton.isHidden = false
        cell.profileStackView.isHidden = false
        cell.waitingDataActivityIndicator.stopAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { _ in
            self.setImageRandom()
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.handleUser = self.userRef.observe(.value, with: { (snapUser) in
            let userModel = self.userTransformer.toUserModel(snap: snapUser)
//            self.gardenersGuestRef = self.gardenerRepository.getGardenersFriendsRef(by: userModel.currentGardener)
            self.gardenerList = userModel.gardenersGuest.sorted()
            print(self.gardenerList)
            self.collectionViewFriends.reloadData()
            
            self.allImageGardener = []
            let dispatchGroup = DispatchGroup()
            userModel.gardenersGuest.forEach { gardenerId in
                dispatchGroup.enter()
                self.gardenerRepository.getReference(for: gardenerId).observeSingleEvent(of: .value, with: { (snapGardener) in
                    let gardener = self.gardenerTransformer.toGardenerModel(snap: snapGardener)
                    var hasLogo = false
                    var images = gardener.metadata.images.map{ $0.key }
                    if (images.contains("logo")) {
                        hasLogo = true
                    }
                    images.forEach { imageName in
                        if (!imageName.contains("logo")) {
                            self.allImageGardener.append(ImagesGardener(gardenerId: gardener.id, imageId: imageName, gardenerName: gardener.metadata.name,
                                hasLogo: hasLogo))
                        }
                    }
                        dispatchGroup.leave()
                })
            }
            dispatchGroup.notify(queue: .main, execute: {
                print(self.allImageGardener)
                self.setHiddenAndPlay()
            })
        })
        

        // Do any additional setup after loading the view.
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.timer?.invalidate()
        self.userRef.removeObserver(withHandle: self.handleUser)
    }

    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func addTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "goToAddGardener", sender: nil)
    }

    @IBAction func userPictureTapped(_ sender: Any) {

        let controller = StoryboardScene.GardernerFriend.gardenerFriendsVC.instantiate()
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    func setHiddenAndPlay() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { _ in
            self.timer?.fire()
            }).invalidate()
    }

    func setImageRandom() {
        guard self.allImageGardener.count > 0 else { return }
        let random = Int.random(in: 0 ..< self.allImageGardener.count)
        let gardenerImage = self.allImageGardener[random]
        self.imageRandom.sd_setImage(with: self.gardenerRepository.getGardenerImage(by: gardenerImage.gardenerId, name: gardenerImage.imageId + ".jpg"))
        if (gardenerImage.hasLogo) {
            self.iconUserProfile.sd_setImage(with: self.gardenerRepository.getGardenerImage(by: gardenerImage.gardenerId, name: "logo.jpg"))
            self.iconUserProfile.isHidden = false
        } else {
            self.iconUserProfile.sd_setImage(with: self.gardenerRepository.getGardenerImage(by: gardenerImage.gardenerId, name: gardenerImage.imageId + ".jpg"))
            self.iconUserProfile.isHidden = false
        }
        self.nameGardener.isHidden = false
        self.zoneBlurFriend.isHidden = false
        self.nameGardener.text = gardenerImage.gardenerName
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AddGardenerNC {
            destination.subscribe = true
            destination.dismissDelegate = self
        }
        if let destination = segue.destination as? SubscribeDetailVC {
            var gardenerId = sender as? String
            destination.currentGardener = gardenerId
        }
    }
}

extension SubscribeVC: FriendsCVCellDelegate {
    
    func didDeleteFriendButton(gardenerId: String) {
        
        let alerteActionSheet = UIAlertController(title: NSLocalizedString("do_you_wish_to_stop_following_this_gardener", comment: "do_you_wish_to_stop_following_this_gardener"), message: "", preferredStyle: .alert)
        alerteActionSheet.view.tintColor = Styles.PlantRBlackColor
        let remove = UIAlertAction(title: NSLocalizedString("confirm", comment: "confirm"), style: .default) { _ in
            self.userRepository.getGardenerGuestReference(for: self.currentUser.uid).child(gardenerId).removeValue()
        }
        let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: nil)
        alerteActionSheet.addAction(remove)
        alerteActionSheet.addAction(cancel)
        
        present(alerteActionSheet, animated: true, completion: nil)
    }
}


extension SubscribeVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.gardenerList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendsCell", for: indexPath) as! FriendsCVCell
        cell.delegate = self
        let gardener = self.gardenerList[indexPath.section]
        self.gardenerRepository.getReference(for: gardener).observeSingleEvent(of: .value, with: { snapGardener in
            var gardenerModel = self.gardenerTransformer.toGardenerModel(snap: snapGardener)
            if !self.gardenerListModels.contains { $0.id == gardenerModel.id } {
                self.gardenerListModels.append(gardenerModel)
            }
            self.setGardenerProperty(cell, gardenerModel: gardenerModel)
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var cell = self.collectionViewFriends.cellForItem(at: indexPath) as! FriendsCVCell
        guard let gardenerId = cell.gardenerId else { return }
        self.performSegue(withIdentifier: "goToSubcribeDetail", sender: gardenerId)
    }
}

extension SubscribeVC: DismissDelegate {
    func didDismiss() {
        if (ScannerService.shared.showLinksGardener) {
            ScannerService.shared.showLinksGardener = false
            self.performSegue(withIdentifier: "goToLinksGardener", sender: nil)
        }
        if (ScannerService.shared.showGoToSubscribe) {
            ScannerService.shared.reset()
        }
    }
}
