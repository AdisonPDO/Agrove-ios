//
//  AccountVC.swift
//  plantR_ios
//
//  Created by Rabissoni on 06/02/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//
// swiftlint:disable type_body_length

import UIKit
import Firebase
import MessageUI
import CoreLocation
import FirebaseUI
import RGPD
import Branch

class AccountVC: UIViewController, DataPickerTextFieldDelegate {
    
    
    @IBOutlet var infosButton: UIButton!
    @IBOutlet var labelUserName: UILabel!
    @IBOutlet var stackViewInformation: UIStackView!
    @IBOutlet var nameGardernerTextField: UITextField!
    @IBOutlet var adressGardenerTextField: UITextField!
    @IBOutlet var cityTextField: DataPickerTextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var currentPasswordTextField: UITextField!
    @IBOutlet var newPasswordTextField: UITextField!
    @IBOutlet var activityIndicatorWaitingScreen: UIActivityIndicatorView!
    @IBOutlet var activityIndicatorInformation: UIActivityIndicatorView!
    @IBOutlet var activityIndicatorHousing: UIActivityIndicatorView!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var rankArrayImageView: [UIImageView]!
    @IBOutlet var barImediateView: UIView!
    @IBOutlet var barAdvanceView: UIView!
    @IBOutlet var barExpertRank: UIView!
    @IBOutlet var rankLabel: UILabel!
    @IBOutlet var rankLabelContrainteCenter: NSLayoutConstraint!
    @IBOutlet var invitationCode: UILabel!
    @IBOutlet var imageTake: UIButton!
    @IBOutlet var localityButton: UIButton!
    @IBOutlet var localityActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var rgpdButton: RGPDButton!
    @IBOutlet weak var MyGardenerInformation: CornerRaduisV!
    //@IBOutlet weak var MyShareGardener: CornerRaduisV!
    @IBOutlet var vRemoveGardener: UIView!
    @IBOutlet var fSelectedGardener: DataPickerTextField!
    @IBOutlet var svScrollView: UIScrollView!
    @IBOutlet var tfPlace: DataPickerTextField!
    @IBOutlet var tfSun: DataPickerTextField!
    @IBOutlet var tfOrient: DataPickerTextField!
    @IBOutlet var vSelectGardener: CornerRaduisV!
    
    @IBOutlet var vOrient: UIView!
    @IBOutlet var vPlace: UIView!
    
    var userRepository: UserRepository!
    var userTransformer: UserTransformer!
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!
    var avatarService: AvatarService!
    let locationManager = CLLocationManager()
    private var currentGardener: String!
    private var errorMessage: String?
    private var currentUser: User!
    private var gardener: GardenerModel?
    private var handleGardener: UInt!
    private var handleUser: UInt!
    private var handleCurrentGardener: UInt!
    private var handleUserProfileImage: UInt!
    private var handleProfileImage: NSObjectProtocol!
    private var userRef: DatabaseReference!
    private var userProfileUIImage: UIImage!
    private var gardenerRef: DatabaseReference!
    private var userCurrentGardenerRef: DatabaseReference!
    private var askedForDeletion = false
    private var arrayGardener: [GardenerDataField] = []
    private var selectedCurrentGardener: String = ""
    var gardeners: [GardenerModel]?
    var pays = PaysUtils()
    
    var indexSun = 0
    var indexPlace = 0
    var indexOrient = 0
    
    enum ImageSource {
        case photoLibrary
        case camera
    }
    struct GardenerDataField  {
        var name: String = ""
        let id: String
    }
    
    var widthPictureCell: CGFloat = 0.0
    
    lazy var imagePicker: UIImagePickerController = {
        let imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        return imagePicker
    }()
    
    func didSelectRow(pickerView: UIPickerView, row: Int, component: Int, identifier: String, value: String) {
        print("HERE")
        guard let currentUser = Auth.auth().currentUser else { return }
        if identifier == "tfGardener" {
            if !arrayGardener.isEmpty && row <= arrayGardener.count {
                self.userRepository.getCurrentGardenerReference(for: currentUser.uid).setValue(arrayGardener[row].id)
            }
        }
        if identifier == FormPickerType.Sun {
            print("Row SUN => \(row)")
            indexSun = row
        }
        if identifier == FormPickerType.Place {
            print("Row places => \(row)")
            indexPlace = row
        }
        if identifier == FormPickerType.Orientation {
            indexOrient = row
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cityTextField.pickerViewDelegate = self

        self.cityTextField.dataValues = pays.getPaysName()
        self.infosButton.titleLabel?.isHidden = true
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.vSelectGardener.isHidden = true
        } else {
            self.vSelectGardener.isHidden = false
        }
        self.fSelectedGardener.pickerViewDelegate = self
        self.tfPlace.pickerViewDelegate = self
        self.tfSun.pickerViewDelegate = self
        self.tfOrient.pickerViewDelegate = self
        
        self.tfPlace.pickerIdentifier = FormPickerType.Place
        self.tfSun.pickerIdentifier = FormPickerType.Sun
        self.tfOrient.pickerIdentifier = FormPickerType.Orientation
        self.fSelectedGardener.pickerIdentifier = "tfGardener"
        
        self.tfPlace.dataValues = PlacesArrayWithoutSelecting
        self.tfSun.dataValues = SunArrayWithoutSelecting
        self.tfOrient.dataValues = OrientArrayWithoutSelecting
        
        currentUser = Auth.auth().currentUser
        self.emailTextField.text = self.currentUser.email
        self.activityIndicatorWaitingScreen.startAnimating()
        self.labelUserName.text = ""
        
        self.userRef = userRepository.getReference(for: self.currentUser.uid)
        self.userCurrentGardenerRef = userRepository.getCurrentGardenerReference(for: self.currentUser.uid)
        
        if let gardeners = gardeners {
            let listGardener = gardeners.map { GardenerDataField(name: $0.metadata.name, id: $0.id) }
            self.arrayGardener = listGardener
            let tmpSelected = listGardener.filter { $0.id == self.currentGardener }
            self.fSelectedGardener.text = tmpSelected.first?.name ?? ""
            self.fSelectedGardener.dataValues = gardeners.map { $0.metadata.name }
        }
        
        getCurrentUserProfileImage()
        rgpdButton.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.handleCurrentGardener = self.userCurrentGardenerRef.observe(.value, with: { (snapshot) in
            self.currentGardener = snapshot.value as? String
            self.gardenerRef?.removeObserver(withHandle: self.handleGardener)
            if (!self.currentGardener.isEmpty) {
                
                var tmpSelected = self.arrayGardener.filter { $0.id == self.currentGardener }
                self.fSelectedGardener.text = tmpSelected.first?.name ?? ""
                
                self.MyGardenerInformation.isHidden = false
                //self.MyShareGardener.isHidden = false
                self.vRemoveGardener.isHidden = false
                self.vSelectGardener.isHidden = false
                self.gardenerRef = self.gardenerRepository.getReference(for: self.currentGardener)
                self.handleGardener = self.gardenerRef.observe(.value, with: { (snapshot) in
                    let gardener = self.gardenerTransformer.toGardenerModel(snap: snapshot)
                    self.gardener = gardener
                    self.indexPlace = gardener.metadata.emplacement
                    self.indexSun = gardener.metadata.ensoleillement
                    self.indexOrient = gardener.metadata.orientation
     
                    self.adressGardenerTextField.text = gardener.metadata.zipCode
                    self.cityTextField.text = self.pays.getNameByCode(code: gardener.metadata.countryCode)
                    self.nameGardernerTextField.text = gardener.metadata.name
                    self.tfPlace.text = PlacesArrayWithoutSelecting[self.indexPlace]
                    self.tfSun.text = SunArrayWithoutSelecting[self.indexSun]
                    self.tfOrient.text = OrientArrayWithoutSelecting[self.indexOrient]
                    self.activityIndicatorWaitingScreen.stopAnimating()
                    self.stackViewInformation.isHidden = false
                    if gardener.type == "parcelle" {
                        self.vPlace.isHidden = true
                        self.vOrient.isHidden = false
                    } else {
                        self.vPlace.isHidden = false
                        self.vOrient.isHidden = true
                    }
                })
            } else {
                self.activityIndicatorWaitingScreen.stopAnimating()
                // ici ---> self.MyShareGardener.isHidden = true
                self.MyGardenerInformation.isHidden = true
                self.vSelectGardener.isHidden = true
                self.vRemoveGardener.isHidden = true
            }
        })
        
        self.handleUser = userRef.observe(.value, with: { (snapshot) in
            let user = self.userTransformer.toUserModel(snap: snapshot)
            
            
            
            let targetIndexRang = user.rank.rawValue
            self.labelUserName.text = "\(user.metadata.firstName) \(user.metadata.lastName)"
            
            switch user.rank {
            case .beginner :
                break
            case .intermediate :
                self.barImediateView.isHidden = false
                self.barImediateView.backgroundColor = Styles.PlantRGreenProgressBarFriend
                self.rankArrayImageView[0].backgroundColor = Styles.PlantRGreenProgressBarFriend
            case .advance :
                self.barAdvanceView.isHidden = false
                self.barAdvanceView.backgroundColor = Styles.PlantRGreenProgressBarFriend
                self.rankArrayImageView[0].backgroundColor = Styles.PlantRGreenProgressBarFriend
                self.rankArrayImageView[1].backgroundColor = Styles.PlantRGreenProgressBarFriend
            case .expert :
                self.barExpertRank.backgroundColor = Styles.PlantRGreenProgressBarFriend
                self.rankArrayImageView[0].backgroundColor = Styles.PlantRGreenProgressBarFriend
                self.rankArrayImageView[1].backgroundColor = Styles.PlantRGreenProgressBarFriend
                self.rankArrayImageView[2].backgroundColor = Styles.PlantRGreenProgressBarFriend
                
            }
            self.rankLabel.text = user.rank.getTitle()
            self.rankLabelContrainteCenter.isActive = false
            self.rankLabelContrainteCenter = self.rankArrayImageView[targetIndexRang].centerXAnchor.constraint(equalTo: self.rankLabel.centerXAnchor)
            self.rankLabelContrainteCenter.isActive = true
            self.rankArrayImageView[targetIndexRang].backgroundColor = Styles.PlantRGreenProgressBarFriend
            self.rankArrayImageView[targetIndexRang].transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
        })
        
        self.handleProfileImage = NotificationCenter.default.addObserver(forName: AvatarService.avatarUpdatedNotification, object: nil, queue: nil) { [weak self] _ in
            self?.getCurrentUserProfileImage()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !askedForDeletion {
            RGPD.shared.hasAllAuthorizations { result in
                if !result {
                    DispatchQueue.main.async {
                        RGPD.shared.showRGPDModally(self)
                    }
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let handleUser = self.handleUser {
            self.userRef.removeObserver(withHandle: self.handleUser)
        }
        if let handleGardener = self.handleGardener {
            self.gardenerRef.removeObserver(withHandle: self.handleGardener)
        }
        if let handleCurrentGardener = self.handleCurrentGardener {
            self.userCurrentGardenerRef.removeObserver(withHandle: self.handleCurrentGardener)
        }
        NotificationCenter.default.removeObserver(self.handleProfileImage)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func housingTapped(_ sender: UIButton) {
        guard self.nameGardernerTextField.text! != "" else {
            self.popOKAlertController(title: NSLocalizedString("put_a_name_to_your_planter", comment: "put_a_name_to_your_planter"))
            return
        }
        sender.isEnabled = false
        self.activityIndicatorHousing.startAnimating()
        let metadata = GardenerMetadataModel(name: self.nameGardernerTextField.text!, city: "", address: "", zipCode: self.adressGardenerTextField.text!, images: self.gardener?.metadata.images ?? [:], emplacement: self.indexPlace, ensoleillement: self.indexSun, orientation: self.indexOrient, countryCode: self.pays.getCodeByName(name: self.cityTextField.text!))
        print(metadata)
        let dictToOwnerGardenerFireBase = self.gardenerTransformer.toDictonary(metadata)
        let newGardenerReference = self.gardenerRepository.getMetadataReference(for: self.currentGardener)
        newGardenerReference.setValue(dictToOwnerGardenerFireBase) { (error, _) in
            self.activityIndicatorHousing.stopAnimating()
            sender.isEnabled = true
            
            if let error = error {
                print(error)
                self.popOKAlertController(title: NSLocalizedString("an_error_has_occurred", comment: "an_error_has_occurred"))
            } else {
                for (index, item) in self.arrayGardener.enumerated() {
                    if (item.id == self.currentGardener) {
                        self.arrayGardener[index].name = metadata.name
                    }
                }
                let tmpSelected = self.arrayGardener.filter { $0.id == self.currentGardener }
                self.fSelectedGardener.text = tmpSelected.first?.name ?? ""
                self.fSelectedGardener.dataValues = self.arrayGardener.map { $0.name }
            }
            self.popOKAlertController(title: NSLocalizedString("modification_done", comment: "modification_done"))
        }
    }
    
    private func sendPopUpIfError (message: String, activity: UIActivityIndicatorView?) {
        activity?.stopAnimating()
        self.popOKAlertController(title: message)
    }
    @IBAction func bRemoveGardener(_ sender: UIButton) {
        let alertController = UIAlertController(title: "\(NSLocalizedString("are_you_sure_you_want_to_remove_your", comment: "are_you_sure_you_want_to_remove_your")) \(self.gardener?.metadata.name ?? "") ?", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: "yes"), style: .default, handler: { _ in
            self.checkRemoveOwner(sender: sender)
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: nil))
        alertController.view.tintColor = Styles.PlantRMainGreen
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func informationTapped(_ sender: UIButton) {
        sender.isEnabled = false
        guard let email = currentUser.email, let newPassword = newPasswordTextField.text, let currentPassword = currentPasswordTextField.text, currentPassword != "" && newPassword != "" else {
            self.popOKAlertController(title: NSLocalizedString("please_fill_all_the_blanks", comment: "please_fill_all_the_blanks"))
            sender.isEnabled = true
            return
        }
        guard currentPassword != newPassword else {
            sendPopUpIfError(message: NSLocalizedString("identical_password", comment: "identical_password"), activity: nil)
            sender.isEnabled = true
            return
        }
        self.activityIndicatorInformation.startAnimating()
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        currentUser.reauthenticateAndRetrieveData(with: credential) { _, error in
            if let error = error {
                self.errorMessage = error.localizedFirebaseAuthDescription
                sender.isEnabled = true
                self.sendPopUpIfError(message: self.errorMessage!, activity: self.activityIndicatorInformation)
            } else {
                self.currentUser.updatePassword(to: newPassword) { (error) in
                    self.errorMessage = error?.localizedFirebaseAuthDescription
                    sender.isEnabled = true
                    if let errorMessage = self.errorMessage {
                        self.sendPopUpIfError(message: errorMessage, activity: self.activityIndicatorInformation)
                    } else {
                        self.sendPopUpIfError(message: NSLocalizedString("the_change_has_been_mad", comment: "the_change_has_been_mad"), activity: self.activityIndicatorInformation)
                    }
                }
            }
        }
    }
    @IBAction func shareGestureTapped(_ sender: UITapGestureRecognizer) {
        guard let gardener = self.gardener else { return }
        
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
    
    /*@IBAction func sendMailTapped(_ sender: UIButton) {
     
     }*/
    
    @IBAction func signOutTapped(_ sender: Any) {
        
        
        let alertController = UIAlertController(title: NSLocalizedString("are_you_sure_you_want_to_disconnect", comment: "are_you_sure_you_want_to_disconnect"), message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: "yes"), style: .default, handler: { _ in
            self.logout()
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: nil))
        alertController.view.tintColor = Styles.PlantRMainGreen
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func logout() {
        removeTopics()
        try! Auth.auth().signOut()
        
    }
    
    fileprivate func removeTopics() {
        let userDefaults = UserDefaults.standard
        var oldTopics = (userDefaults.string(forKey: GlobalConsts.ChannelTopics) ?? "").split(separator: "|")
        for topicsToUnsubscribe in oldTopics {
            Messaging.messaging().unsubscribe(fromTopic: String(topicsToUnsubscribe))
        }
        var topicsToStore = ""
        userDefaults.set(topicsToStore, forKey: GlobalConsts.ChannelTopics)
    }
    
    private func presentWithSource(_ source: UIImagePickerController.SourceType) {
        imagePicker.sourceType = source
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func takePicture(_ sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            self.presentWithSource(.photoLibrary)
            return
        }
        let alerteActionSheet = UIAlertController(title: "", message: NSLocalizedString("select_a_category", comment: "select_a_category"), preferredStyle: .actionSheet)
        alerteActionSheet.view.tintColor = Styles.PlantRBlackColor
        let camera = UIAlertAction(title: NSLocalizedString("camera", comment: "camera"), style: .default) { _ in
            self.presentWithSource(.camera)
        }
        let gallery = UIAlertAction(title: NSLocalizedString("photo_gallery", comment: "photo_gallery"), style: .default) { _ in
            self.presentWithSource(.photoLibrary)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: nil)
        alerteActionSheet.addAction(camera)
        alerteActionSheet.addAction(gallery)
        alerteActionSheet.addAction(cancel)
        
        if let popover = alerteActionSheet.popoverPresentationController {
            popover.sourceView = imageTake.superview
            popover.sourceRect = imageTake.frame
        }
        present(alerteActionSheet, animated: true, completion: nil)
    }
    
    @IBAction func showInfos(_ sender: Any) {
        let alertController = UIAlertController(title: "Info", message: "Ces informations nous permettront de vous suggérer des plantes adaptées à votre environnement : \n \n  ● si vous avez opté pour un potager classique ou \n \n ● dès le premier jour de mise en fonctionnement de votre kit potager connecté.\n \n Ensuite, lorsque les capteurs de climat auront eu le temps de collecter suffisamment de données sur votre environnement, les suggestions seront affinées.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
        alertController.addAction(cancelAction)
        alertController.view.tintColor = Styles.PlantRMainGreen
        present(alertController, animated: true)
        
    }
    @IBAction func localisationTapped(_ sender: Any) {
        print("LOCALISATION TAPPED")
        if (CLLocationManager.locationServicesEnabled()) {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                let alertController = UIAlertController(title: NSLocalizedString("you_must_authorize_the_localization_of_the_agrove", comment: "you_must_authorize_the_localization_of_the_agrove"), message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("edit", comment: "edit"), style: .default, handler: { _ in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }))
                alertController.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: nil))
                alertController.view.tintColor = Styles.PlantRMainGreen
                self.present(alertController, animated: true, completion: nil)
                
            case .authorizedAlways, .authorizedWhenInUse :
                self.localityButton.isHidden = true
                self.localityActivityIndicator.startAnimating()
                locationManager.startUpdatingLocation()

            default:
                self.popOKAlertController(title: NSLocalizedString("an_error_occurred_while_retrieving_your_address", comment: "an_error_occurred_while_retrieving_your_address"))
            }
        } else {
            print("LOCALISATION false")
            self.popOKAlertController(title: NSLocalizedString("you_need_to_enable_location_in_order_to_retrieve_your_address", comment: "you_need_to_enable_location_in_order_to_retrieve_your_address"))
        }
    }
    
    private func getCurrentUserProfileImage() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let userStorageProfileImage = userRepository.getImageProfile(for: currentUser.uid)
        profileImageView.sd_setImage(with: userStorageProfileImage, placeholderImage: Asset.placeholderProfil.image, completion: { [weak self] (image, error, _, _) in
            guard var newImage = image else {
                self?.profileImageView.image = Asset.placeholderProfil.image
                return
            }
            self?.profileImageView.image = newImage
        })
    }
    @IBAction func rgpdButtonTapped(_ sender: RGPDButton) {
        RGPD.shared.showAccountModally(self) { didAskForSuppression in
            
            if didAskForSuppression {
                print("* SUPPRIMER *")
                print(didAskForSuppression)
                /*Auth.auth().currentUser?.delete(completion: { error in
                    if let error = error {
                        print(error)
                        self.popOKAlertController(title: "Une erreur est survenue lors de la suppression !")
                    }
                })*/
            }
        }
    }
}
extension AccountVC {
    
    private func reSetArrayAndReload(_ newGardeners: [GardenerModel])
    {
        self.gardeners = newGardeners
        self.arrayGardener = newGardeners.map { GardenerDataField(name: $0.metadata.name, id: $0.id) }
        self.fSelectedGardener.dataValues = newGardeners.map { $0.metadata.name }
    }
    
    private func checkRemoveOwner(sender: UIButton) {
        guard let gardener = gardener, let gardeners = gardeners else {
            sender.isEnabled = true
            return
        }
        let gardenerTemp = gardener
        let teamList = gardener.owners.filter { $0.key != currentUser.uid }
        if (teamList.count >= 1) {
            // retire la gardener et set new current gardener
            let newGardeners = gardeners.filter { $0.id != gardener.id }
            if newGardeners.isEmpty {
                self.userRepository.getCurrentGardenerReference(for: currentUser.uid).setValue("")
            }
            self.gardenerRepository.getGardenersOwnersRef(by: gardener.id).child(currentUser.uid).removeValue()
            self.popOKAlertController(title: "\(NSLocalizedString("your", comment: "your")) \(gardenerTemp.metadata.name) \(NSLocalizedString("is_no_longer_part_of_your_garden", comment: "is_no_longer_part_of_your_garden"))")
            self.reSetArrayAndReload(newGardeners)
            self.svScrollView.setContentOffset(.zero, animated: true)
            sender.isEnabled = true
        } else {
            resetGardener(gardener, gardeners, sender)
        }
    }
    
    private func resetGardener(_ gardener: GardenerModel, _ gardeners: [GardenerModel], _ sender: UIButton) {
        let gardenerTemp = gardener
        if (gardener.id.contains("Classic")) {
            
            let newGardeners = gardeners.filter { $0.id != gardener.id }
            if newGardeners.isEmpty {
                self.userRepository.getCurrentGardenerReference(for: currentUser.uid).setValue("", withCompletionBlock: { error, resp in
                    if (error == nil) {
                        self.gardenerRepository.getReference(for: gardener.id).removeValue()
                    }
                })
            } else {
                self.userRepository.getCurrentGardenerReference(for: currentUser.uid).setValue(newGardeners.first!.id, withCompletionBlock: { error, resp in
                    if (error == nil) {
                        self.gardenerRepository.getReference(for: gardener.id).removeValue()
                    }
                })
            }
            self.popOKAlertController(title: "\(NSLocalizedString("your", comment: "your")) \(gardenerTemp.metadata.name)\(NSLocalizedString("is_no_longer_part_of_your_garden", comment: "is_no_longer_part_of_your_garden"))")
            self.reSetArrayAndReload(newGardeners)
            self.svScrollView.setContentOffset(.zero, animated: true)
            sender.isEnabled = true
        } else {
            self.gardenerRepository.getReference(for: gardener.id).child("dimension").removeValue()
            self.gardenerRepository.getReference(for: gardener.id).child("climat").removeValue()
            self.gardenerRepository.getReference(for: gardener.id).child("owners").removeValue()
            self.gardenerRepository.getReference(for: gardener.id).child("ispublic").removeValue()
            self.gardenerRepository.getReference(for: gardener.id).child("type").removeValue()
            self.gardenerRepository.getReference(for: gardener.id).child("metadata").removeValue(completionBlock: { [self] error, ref in
                if (error == nil) {
                    let newGardeners = gardeners.filter { $0.id != gardener.id }
                    if newGardeners.isEmpty {
                        self.userRepository.getCurrentGardenerReference(for: self.currentUser.uid).setValue("")
                    } else {
                        self.userRepository.getCurrentGardenerReference(for: currentUser.uid).setValue(newGardeners.first!.id)
                    }
                    self.svScrollView.setContentOffset(.zero, animated: true)
                    self.reSetArrayAndReload(newGardeners)
                    self.popOKAlertController(title: "\(NSLocalizedString("your", comment: "your")) \(gardenerTemp.metadata.name) \(NSLocalizedString("is_no_longer_part_of_your_garden", comment: "is_no_longer_part_of_your_garden"))")
                    sender.isEnabled = true
                    
                } else {
                    self.svScrollView.setContentOffset(.zero, animated: true)
                    self.popOKAlertController(title: NSLocalizedString("a_problem_occurred_when_removing_the_connected_vegetable_garden", comment: "a_problem_occurred_when_removing_the_connected_vegetable_garden"))
                    sender.isEnabled = true
                }
            })
        }
    }
}
extension AccountVC: RGPDButtonDelegate {
    func didAskForDeletion() {
        print("* SUPPRIMER *")
        Auth.auth().currentUser?.delete(completion: { error in
            if let error = error {
                print(error)
            }
            self.removeTopics()
            try! Auth.auth().signOut()
        })
    }
}

extension AccountVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        avatarService.updateCurrentUserImageProfile(image)
        dismiss(animated: true, completion: nil)
    }
}

extension AccountVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lat = locations.last?.coordinate.latitude, let long = locations.last?.coordinate.longitude {
            lookUpCurrentLocation { geoLoc in
                guard let localisation = geoLoc else { return }
                guard let locality = localisation.locality, let name = localisation.name else { return }
                self.adressGardenerTextField.text = name
                self.cityTextField.text = locality
                self.localityActivityIndicator.stopAnimating()
                self.localityButton.isHidden = false
                self.locationManager.stopUpdatingLocation()
            }
        } else {
            self.localityActivityIndicator.stopAnimating()
            self.localityButton.isHidden = false
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
