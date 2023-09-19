//
//  MenuVC.swift
//  plantR_ios
//
//  Created by Rabissoni on 06/02/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//
// swiftlint:disable type_body_length

import UIKit
import Firebase
import FirebaseUI
import Foundation
import RGPD
import FirebaseCrashlytics

protocol DismissDelegate {
    func didDismiss()
}

class MenuVC: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    
    @IBOutlet var cornerView: UIView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var accountButton: UIButton!
    @IBOutlet var leftArrowButton: UIButton!
    @IBOutlet var rightArrowButton: UIButton!
    @IBOutlet var collectionViewMenu: UICollectionView!
    @IBOutlet var menuButtons: [UIButton]!
    @IBOutlet var rankHeaderView: UILabel!
    @IBOutlet var userNameHeaderView: UILabel!
    @IBOutlet var activityIndicatorHeaderView: UIActivityIndicatorView!
    @IBOutlet var cornerViewGardenerNameRank: UIStackView!
    @IBOutlet var userIconImage: CIRoundedImageView!
    
    @IBOutlet weak var alertMyGardener: CIRoundedView!
    @IBOutlet weak var alertMyPlants: CIRoundedView!
    @IBOutlet weak var alertMyTasks: CIRoundedView!
    @IBOutlet weak var alertMyTeams: CIRoundedView!
    
    @IBOutlet weak var numberOfAlertMyGardener: UILabel!
    @IBOutlet weak var numberOfAlertMyPlants: UILabel!
    @IBOutlet weak var numberOfAlertMyTeam: UILabel!
    @IBOutlet weak var numberOfAlertMyTasks: UILabel!
    
    
    @IBOutlet weak var MyGardenerButton: UIButton!
    @IBOutlet weak var MyPlantsButton: UIButton!
    @IBOutlet weak var MyMissionsButton: UIButton!
    @IBOutlet weak var MyTeamsButton: UIButton!
    @IBOutlet weak var visitedUserLabel: UILabel!
    @IBOutlet var ivVisitedAcceuil: UIImageView!
    
    
    var branchGoToOwner = false
    var branchGoToGuest = false
    var branchId: String?
    var visitedUser = false
    
    var isFirstlLoad = false
    var isFirstSelectCurrentGardener = true
    var isFinishLoad = true
    var indexLoad = -1
    var maxGardener = 0
    
    var userRepository: UserRepository!
    var userTransformer: UserTransformer!
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!
    var plantsService: PlantsService!
    
    
    private var gardeners: [GardenerModel] = []
    private var currentUser: User!
    private var currentGardener: String!
    
    private var userRef: DatabaseReference!
    private var gardenersRef: DatabaseReference!
    private var userStorageProfileImage: StorageReference!
    private var gardenerAlertTipsRef: DatabaseReference!
    
    
    private var handleAddGardeners: UInt?
    private var handleRemoveGardeners: UInt?
    private var handleUser: UInt?
    private var handleVisitedUser: NSObjectProtocol?
    private var handleAddGardener: NSObjectProtocol?
    private var handleProfileImage: NSObjectProtocol?
    private var handleRefreshGardener: NSObjectProtocol?
    private var handleGardeners: [ReferenceHandle] = []
    private var handleTips: UInt?
    var boldFont: UIFont? {
        return UIDevice.current.userInterfaceIdiom == .pad ? UIFont(name: "Lato-Bold", size: 26) : UIFont(name: "Lato-Bold", size: 22)
    }
    
    var regularFont: UIFont? {
        return UIDevice.current.userInterfaceIdiom == .pad ? UIFont(name: "Lato-Regular", size: 26) : UIFont(name: "Lato-Regular", size: 22)
    }
    
    var circleIndicator: UIView = {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        
        view.backgroundColor = Styles.PlantRMainGreen
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    fileprivate func setCenterForIndicator(for buttonIndex: Int) {
        
        let button = self.menuButtons[buttonIndex]
        let centerY = button.superview!.convert(button.center, to: self.view).y
        
        circleIndicator.center = CGPoint(x: -10, y: centerY)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*if let destination = segue.destination as? ScannerVC {
         destination.dismissDelegate = self
         }*/
        if let destination = segue.destination as? AddToFollowVC {
            destination.dismissDelegate = self
            AddGardenerService.shared.reset()
        }
        if let destination = segue.destination as? AddGardenerNC {
            destination.addGardener = true
            destination.subscribe = false
            destination.dismissDelegate = self
            AddGardenerService.shared.reset()
        }
        if let destination = segue.destination as? AccountVC {
            self.isFinishLoad = true
            self.isFirstSelectCurrentGardener = true
            destination.gardeners = gardeners
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicatorHeaderView.startAnimating()
        currentUser = Auth.auth().currentUser
        
        NotificationService.shared.scheduleNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
        headerView.layer.shadowColor = UIColor.black.cgColor
        headerView.layer.shadowRadius = 4
        headerView.layer.shadowOpacity = 0.5
        headerView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        
        resetFont()
        
        
        self.userNameHeaderView.text = ""
        self.rankHeaderView.text = ""
        
        self.userRef = userRepository.getReference(for: self.currentUser.uid)
        self.gardenersRef = userRepository.getGardenersReference(for: currentUser.uid)
        
        if (NotificationService.shared.object != nil) {
            if let userInfo = NotificationService.shared.object, let type = userInfo["type"] as? String {
                switch type {
                case "taskDone":
                    if let plantUID = userInfo["plantUID"] as? String, let stage = userInfo["stage"] as? String, let gardenerId = userInfo["gardenerId"] as? String, let taskName = userInfo["taskName"] as? String, let taskId = userInfo["taskId"] as? String {
                        showTask(plantUID: plantUID, stage: stage, gardenerId: gardenerId, taskName: taskName, taskId: taskId)
                        
                    }
                default:
                    return
                }
            }
            NotificationService.shared.object = nil
        }
    }
    
    @objc func imageTapped()
    {
        if UIDevice.current.userInterfaceIdiom == .pad {
            perform(segue: StoryboardSegue.Home.goToMyPlantRIpad)
        } else {
            perform(segue: StoryboardSegue.Home.goToMyPlantRIphone)
        }
    }

    func showTask(plantUID: String, stage: String, gardenerId: String, taskName: String, taskId: String) {
        let controller = StoryboardScene.TasksAndTips.newTaskDetailVC.instantiate()
        
        controller.gardenerId = gardenerId
        controller.taskName = taskName
        controller.stage = stage
        controller.plantUID = plantUID
        controller.taskId = taskId
        controller.notification = true
        
        self.present(controller, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.isFirstlLoad {
            self.menuButtons[0].titleLabel?.font = self.boldFont
            self.view.addSubview(self.circleIndicator)
            self.setCenterForIndicator(for: 0)
            isFirstlLoad = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        RGPD.shared.hasAllAuthorizations { hasAuthorizations in
            DispatchQueue.main.async {
                if !hasAuthorizations {
                    RGPD.shared.showRGPDModally(self)
                }
            }
        }
        
        activityIndicatorHeaderView.startAnimating()
        gardeners = []
        collectionViewMenu.reloadData()
        leftArrowButton.isHidden = true
        rightArrowButton.isHidden = true
        getCurrentUserProfileImage()
        self.isFirstSelectCurrentGardener = true
        self.isFinishLoad = true
        
        self.handleUser = self.userRef.observe(.value, with: { (snapshot) in
            let user = self.userTransformer.toUserModel(snap: snapshot)
            if (user.currentGardener.isEmpty) {
                if (user.currentGardener.isEmpty && !user.gardeners.isEmpty) {
                    self.userRepository.getCurrentGardenerReference(for: user.id).setValue(self.gardeners.first)
                }
            }
            if (user.gardeners.count > 0) {
                print("* ICI JE RENTRE *")
                self.removeAndSetTopics(gardeners: user.gardeners)
                UserService.shared.visitedUser = false
                self.setupNonVisiteur()
            } else {
                print("* ICI JE RENTRE true *")
                self.removeAndSetTopics(gardeners: user.gardeners)
                UserService.shared.visitedUser = true
                self.setupVisiteur()
            }
            self.maxGardener = user.gardeners.count
            self.rankHeaderView.text = user.rank.getTitle()
            self.userNameHeaderView.text = ("\(user.metadata.firstName) \(user.metadata.lastName)")
            self.cornerViewGardenerNameRank.isHidden = false
            if user.gardeners.contains(user.currentGardener) {
                self.currentGardener = user.currentGardener
            } else if !user.gardeners.isEmpty {
                if !self.gardeners.isEmpty {
                    self.selectGardenerAndRefreshArrows(0, animated: true)
                }
            } else {
                // TODO: send to setup a gardener screen
                UserService.shared.visitedUser = true
                self.setupVisiteur()
            }
        })
        
        handleAddGardeners = self.gardenersRef.observe(.childAdded) { (snap) in
            let gardenerId = snap.key
            let reference = self.gardenerRepository.getReference(for: gardenerId)
            let handle = reference.observe(.value, with: { snap in
                let gardener = self.gardenerTransformer.toGardenerModel(snap: snap)
                if let existingIndex = self.gardeners.firstIndex(where: { $0.id == snap.key }) {
                    self.gardeners[existingIndex] = gardener
                    self.collectionViewMenu.reloadSections(IndexSet(integer: existingIndex))
                } else {
                    self.gardeners.append(gardener)
                    let newIndex = self.gardeners.count - 1
                    self.collectionViewMenu.insertSections(IndexSet(integer: newIndex))

                    if (self.currentGardener == gardenerId) {
                        self.indexLoad = newIndex
                    }
                    if (self.isFinishLoad && self.isFirstSelectCurrentGardener && self.gardeners.count >= self.maxGardener && self.indexLoad > -1) {
                        self.isFirstSelectCurrentGardener = false
                        self.isFinishLoad = false
                        self.activityIndicatorHeaderView.stopAnimating()
                        self.selectGardenerAndRefreshArrows(self.indexLoad, animated: false)
                    }
                }
                if self.currentGardener == gardener.id {
                    self.initViewAllAlert(gardener: gardener)
                }
            })
            self.handleGardeners.append(ReferenceHandle(reference: reference, handle: handle))
        }
        handleRemoveGardeners = gardenersRef.observe(.childRemoved) { (snap) in
            let gardenerId = snap.key
            guard let deletedGardenerIndex = self.gardeners.firstIndex(where: { $0.id == gardenerId }) else { return }
            self.gardeners.remove(at: deletedGardenerIndex)
            self.collectionViewMenu.deleteSections(IndexSet(integer: deletedGardenerIndex))
            if self.currentGardener == gardenerId {
                if !self.gardeners.isEmpty {
                    self.selectGardenerAndRefreshArrows(0, animated: true)
                }
            } else {
                self.refreshArrows()
            }
            
        }
        
        self.handleProfileImage = NotificationCenter.default.addObserver(forName: AvatarService.avatarUpdatedNotification, object: nil, queue: nil) { [weak self] _ in
            self?.getCurrentUserProfileImage()
        }
        /*self.handleAddGardener = NotificationCenter.default.addObserver(forName: AvatarService.avatarUpdatedNotification, object: nil, queue: nil) { [weak self] _ in
         self?.performSegue(withIdentifier: "goToAddGardener", sender: nil)
         }*/
        
        self.handleVisitedUser = NotificationCenter.default.addObserver(forName: UserService.visitedUserNotification, object: nil, queue: nil) { [weak self] _ in
            self?.perform(segue: StoryboardSegue.Home.goToSubscribe)
        }
        self.handleRefreshGardener = NotificationCenter.default.addObserver(forName: UserService.refreshGardenerNotification, object: nil, queue: nil) { [weak self] _ in
            self?.selectGardenerAndRefreshArrows(self!.indexLoad, animated: false)
        }
    }
    
    fileprivate func removeAndSetTopics(gardeners: [String]) {
        let userDefaults = UserDefaults.standard
        print("* removeAndSetTopics *")
        var oldTopics = (userDefaults.string(forKey: GlobalConsts.ChannelTopics) ?? "").split(separator: "|")
        print("* OLD TOPICS \(oldTopics) *")
        for topicsToUnsubscribe in oldTopics {
            Messaging.messaging().unsubscribe(fromTopic: String(topicsToUnsubscribe))
        }
        var topicsToStore = ""
        for gardener in gardeners {
            Messaging.messaging().subscribe(toTopic: gardener)
            topicsToStore += "\(gardener)|"
        }
        print("* TOPICS store \(topicsToStore) *")
        userDefaults.set(topicsToStore, forKey: GlobalConsts.ChannelTopics)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let handleProfileImage = handleProfileImage {
            NotificationCenter.default.removeObserver(handleProfileImage)
        }
        if let handleAddGardener = handleAddGardener {
            NotificationCenter.default.removeObserver(handleAddGardener)
        }
        if let handleVisitedUser = handleVisitedUser {
            NotificationCenter.default.removeObserver(handleVisitedUser)
        }
        if let handleRefreshGardener = handleRefreshGardener {
            NotificationCenter.default.removeObserver(handleRefreshGardener)
        }
        if let handleUser = handleUser {
            userRef.removeObserver(withHandle: handleUser)
        }
        if let handleAddGardeners = handleAddGardeners {
            gardenersRef.removeObserver(withHandle: handleAddGardeners)
        }
        if let handleRemoveGardeners = handleRemoveGardeners {
            gardenersRef.removeObserver(withHandle: handleRemoveGardeners)
        }
        if let handleTips = self.handleTips {
            self.gardenerAlertTipsRef.removeObserver(withHandle: handleTips)
        }
        handleGardeners.forEach { $0.reference.removeObserver(withHandle: $0.handle) }
        handleGardeners = []
        self.isFirstSelectCurrentGardener = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        cornerView.layer.cornerRadius = cornerView.frame.width / 2.0
        cornerView.layer.masksToBounds = true
        if let flowLayout = collectionViewMenu.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = collectionViewMenu.frame.size
        }
    }
    
    private func resetFont() {
        menuButtons.forEach({
            $0.titleLabel?.font = regularFont
        })
    }
    
    private func selectGardenerAndRefreshArrows(_ index: Int, animated: Bool) {

        let indexPath = IndexPath(item: 0, section: index)
        self.collectionViewMenu.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
        self.currentGardener = self.gardeners[index].id
        self.initViewAllAlert(gardener: self.gardeners[index])
        self.userRepository.getCurrentGardenerReference(for: self.currentUser.uid).setValue(self.currentGardener)
        self.refreshArrows(currentGardenerIndex: index)
    }
    
    private func refreshArrows() {
        guard let currentGardenerIndex = gardeners.firstIndex(where: { $0.id == currentGardener }) else { return }
        self.refreshArrows(currentGardenerIndex: currentGardenerIndex)
    }
    
    private func refreshArrows(currentGardenerIndex: Int) {
        leftArrowButton.isHidden = currentGardenerIndex <= 0
        rightArrowButton.isHidden = currentGardenerIndex >= gardeners.count - 1
    }
    
    fileprivate func initViewAllAlert(gardener: GardenerModel) {
        self.setupMyGardenerAlert(gardener)
        self.setupMyPlantsAlert(gardener)
        self.setupMyTeamAlert(gardener)
        self.setupMyTasksAlert(gardener)
    }
    
    fileprivate func setupMyGardenerAlert(_ gardener: GardenerModel) {
        self.alertMyGardener.isHidden = true
        let mirror = Mirror(reflecting: gardener.tips)
        
        let tips = mirror.children.filter { $0.label != "temperature" && $0.value as! Bool }
        if !tips.isEmpty {
            self.alertMyGardener.isHidden = false
            self.numberOfAlertMyGardener.text = String(tips.count)
        }
    }
    
    fileprivate func setupMyTasksAlert(_ gardener: GardenerModel) {
        self.alertMyTasks.isHidden = true
        let currentStartOfDay = Calendar.current.startOfDay(for: Date())
        
        let tasksBefore = gardener.taskPlants.filter { $0.task.doneBy == nil && Calendar.current.startOfDay(for: $0.task.date) <= currentStartOfDay }
        
//
//        let list = gardener.taskPlants.filter ({
//            let status = $0.status
//            switch (status) {
//            case FilterTaskConst.Planter:
////                        print("Planter - \($0.task.title.lowercased()) - \(self.plantsService.filterTask.planter) - => \(self.plantsService.filterTask.planter.contains($0.task.title.lowercased()))")
//                return self.plantsService.filterTask.planter.contains($0.task.title.lowercased())
//            case FilterTaskConst.Semer:
////                        print("Semer - \($0.task.title.lowercased()) - \(self.plantsService.filterTask.semer) -  => \(self.plantsService.filterTask.semer.contains($0.task.title.lowercased()))")
//                return self.plantsService.filterTask.semer.contains($0.task.title.lowercased())
//            default:
//                return true
//            }
//        })
//
//        print("noooooooooooo : \(list.count)")
        
        
        if !tasksBefore.isEmpty {
            self.alertMyTasks.isHidden = false
            self.numberOfAlertMyTasks.text = "\(tasksBefore.count)"
            // test pour check les missions notifiées print("tototototo : \(tasksBefore.map{$0.task.title})")
        }
    }
    
    fileprivate func setupMyTeamAlert(_ gardener: GardenerModel) {
        self.alertMyTeams.isHidden = true
        if !gardener.subcribemember.isEmpty {
            self.alertMyTeams.isHidden = false
            self.numberOfAlertMyTeam.text = "\(gardener.subcribemember.count)"
        }
    }
    
    fileprivate func setupMyPlantsAlert(_ gardener: GardenerModel) {
        self.alertMyPlants.isHidden = true
        
        let date = Date()
        let dateComponent = Calendar.current.dateComponents([.month], from: date)
        guard let currentlyMonth = dateComponent.month else { return }
        
        let wishlist = gardener.wishlist.filter {
            checkBetweenStartAndEnd(start: $0.value.plantingPeriod.startMonth, end: $0.value.plantingPeriod.endMonth, current: currentlyMonth) ||
                checkBetweenStartAndEnd(start: $0.value.sowingPeriod.startMonth, end: $0.value.sowingPeriod.endMonth, current: currentlyMonth)
        }
        if !wishlist.isEmpty {
            self.alertMyPlants.isHidden = false
            self.numberOfAlertMyPlants.text = "\(wishlist.count)"
        }
    }
    
    @IBAction func myPlantRTapped(_ sender: UIButton) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            perform(segue: StoryboardSegue.Home.goToMyPlantRIpad)
        } else {
            perform(segue: StoryboardSegue.Home.goToMyPlantRIphone)
        }
    }
    
    
    @IBAction func myPlantsTapped(_ sender: Any) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            perform(segue: StoryboardSegue.Home.goToMyPlantsIPad)
        } else {
            perform(segue: StoryboardSegue.Home.goToMyPlantsIPhone)
        }
    }
    
    @IBAction func arrowTapped(_ sender: UIButton) {
        guard let currentGardenerIndex = self.gardeners.firstIndex(where: { $0.id == self.currentGardener }) else { return }
        if sender == leftArrowButton {
            self.selectGardenerAndRefreshArrows(currentGardenerIndex - 1, animated: true)
        } else if sender == rightArrowButton {
            self.selectGardenerAndRefreshArrows(currentGardenerIndex + 1, animated: true)
        }
    }
    
    @IBAction func addGardenerTapped(_ sender: Any) {
        performSegue(withIdentifier: "goToAddGardener", sender: nil)
        //        performSegue(withIdentifier: "goToAddGardener", sender: nil)
    }
    
    @IBAction func SelectButton(_ sender: UIButton) {
        
        resetFont()
        
        sender.titleLabel?.font = boldFont
        
        UIView.animate(withDuration: 0.2) {
            self.setCenterForIndicator(for: self.menuButtons.firstIndex(of: sender) ?? 0)
        }
    }
    
    private func getCurrentUserProfileImage() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let userStorageProfileImage = userRepository.getImageProfile(for: currentUser.uid)
        let url = NSURL.sd_URL(with: userStorageProfileImage)
        userIconImage.sd_setImage(with: userStorageProfileImage, placeholderImage: Asset.placeholderProfil.image)
    }
    
    fileprivate func setupVisiteur() {
        self.MyGardenerButton.isEnabled = false
        self.MyGardenerButton.alpha = 0.5
        self.MyPlantsButton.isEnabled = false
        self.MyPlantsButton.alpha = 0.5
        self.MyMissionsButton.isEnabled = false
        self.MyMissionsButton.alpha = 0.5
        self.MyTeamsButton.isEnabled = false
        self.MyTeamsButton.alpha = 0.5
        self.visitedUserLabel.isHidden = true
        if(NSLocale.current.languageCode == "fr"){
            self.ivVisitedAcceuil.image = UIImage(named: "message_accueil")
        }else{
            self.ivVisitedAcceuil.image = UIImage(named: "message_accueil_en")
        }
        self.ivVisitedAcceuil.isHidden = false
        self.alertMyGardener.isHidden = true
    }
    
    fileprivate func setupNonVisiteur() {
        self.MyGardenerButton.isEnabled = true
        self.MyGardenerButton.alpha = 1
        self.MyPlantsButton.isEnabled = true
        self.MyPlantsButton.alpha = 1
        self.MyMissionsButton.isEnabled = true
        self.MyMissionsButton.alpha = 1
        self.MyTeamsButton.isEnabled = true
        self.MyTeamsButton.alpha = 1
        self.visitedUserLabel.isHidden = true
        self.ivVisitedAcceuil.isHidden = true
    }
    
}

extension MenuVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.gardeners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GardenerMenuCell", for: indexPath) as! HeaderCollectionViewCell
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MenuVC.imageTapped))
        cell.isUserInteractionEnabled = true
        cell.addGestureRecognizer(tapGestureRecognizer)
        
        print("-> \(gardeners[indexPath.section].type)")
        print("-> \(indexPath.section)")
        let gardener = gardeners[indexPath.section]
        setImageGenericGardenerWhite(gardener: gardener, ivCenter: cell.ivCenter)
        
        cell.labelNameGardener.text = gardener.metadata.name
        return cell
    }
}

extension MenuVC: DismissDelegate {
    func didDismiss() {
        if (ScannerService.shared.showLinksGardener) {
            ScannerService.shared.showLinksGardener = false
            self.performSegue(withIdentifier: "goToLinksGardener", sender: nil)
        }
        if (ScannerService.shared.showGoToSubscribe) {
            ScannerService.shared.reset()
            self.performSegue(withIdentifier: "goToSubscribe", sender: nil)
        }
    }
}



