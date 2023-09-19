//
//  PlantRVC.swift
//  plantR_ios
//
//  Created by Rabissoni on 06/02/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//
// swiftlint:disable type_body_length

import UIKit
import Firebase
import FirebaseUI
import LinearProgressView

class PlantRVC: UIViewController {

    
    @IBOutlet var collectionViewPicture: UICollectionView!
    @IBOutlet var leftArrowButton: UIButton!
    @IBOutlet var rightArrowButton: UIButton!
    @IBOutlet var imageTake: UIButton!
    @IBOutlet var temperatureHighLabel: UILabel!
    @IBOutlet var windNowLabel: UILabel! 
    @IBOutlet var weatherImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var alertTipsClimatButton: UIButton!
    @IBOutlet var alertTipsStatButton: UIButton!
    @IBOutlet var roundedAlertClimat: UIImageView!
    @IBOutlet var roundedAlertStat: UIImageView!
  
    @IBOutlet var humidityLabelTxt: UILabel!
    @IBOutlet var cardGarden: CardView!
    @IBOutlet var climatTitle: UILabel!
    @IBOutlet var contentsIphone: UIStackView!
    
    @IBOutlet var cardTemperature: UILabel!
    @IBOutlet var cardLuminosity: UILabel!
    @IBOutlet var cardAirHumidity: UILabel!
    @IBOutlet var cardPressure: UILabel!
    @IBOutlet var luminosityIcon: UIImageView!
    @IBOutlet var luminosityLabel: UILabel!
    
    @IBOutlet var myPlantView: UIView!
    
    @IBOutlet var gardenerName: UILabel!
    @IBOutlet weak var vCircle: UIView!
    @IBOutlet weak var ivCircle: ImageViewRoundSubViews!
    @IBOutlet weak var vCircularGlobal: CircularProgressSubviews!
    @IBOutlet weak var vCircleShadow: ViewRoundSubViews!
    @IBOutlet weak var lGlobal: UILabel!
    
    @IBOutlet weak var linearProgressHumidity: LinearProgressView!
    @IBOutlet weak var linearProgressBattery: LinearProgressView!
    @IBOutlet weak var linearProgressWater: LinearProgressView!
    
    
    @IBOutlet var labelWaterStatus: UILabel!
    @IBOutlet var labelHumidityStatus: UILabel!
    @IBOutlet var labelBatteryStatus: UILabel!
    
    @IBOutlet weak var contentIpad: UIStackView!
    @IBOutlet weak var contentTips: UIImageView!
    
    @IBOutlet weak var backButt: UIButton!
    @IBOutlet var svIpadProgressBottom: UIStackView!
    @IBOutlet var svIphoneProgressBottom: UIStackView!
    
    
    private var gardenersMetadataRef: DatabaseQuery!
    private var handleGardenersClimat: UInt!
    private var handleGardenersMetadata: UInt!
    public var isNotif = false
    public var notifIdGardener = ""
        
    private var dataSourceImages: FUICollectionViewDataSource!
    private var dataSourceStats: FUICollectionViewDataSource!
    
    private var currentGardener: String!
    private var currentUser: User!
    private var tips: TipsModel!
    
    private var userCurrentGardenerRef: DatabaseReference!
    private var gardenerImagesRef: DatabaseReference!
    private var gardenerPictureRef: StorageReference!
    //private var gardenerStatsRef: DatabaseReference!
    private var gardenerTipsRef: DatabaseReference!
    private var gardenerStatsTest : DatabaseReference!
    private var currentNotifGardener: DatabaseReference?
    
    // LOST LORA CONNEXION
    @IBOutlet var alertView: UIView!
    @IBOutlet var alertLabel: UILabel!
    
    
    private var handleCurrentGardener: UInt?
    private var handlePictures: UInt?
    private var handleTips: UInt?
    //private var handleStats: UInt?
    
    private var arrayTips: [String: Bool] = [:]
    
    private var numberOfPictures: Int!
    private var currentPicture: Int!
    
    var userRepository: UserRepository!
    var userTransformer: UserTransformer!
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!
    
    @IBOutlet var waterLvlTitle: UILabel!
    @IBOutlet var waterLvlCard: CardView!
    @IBOutlet var irrigButton: UIButton!
    
    
    var getWeather: GetWeather!
    var tipsService: TipsService!
    var classic = true
    
    var humidityState: String = NSLocalizedString("perfectly_humid", comment: "perfectly_humid")
    var baterryState: String = NSLocalizedString("good", comment: "good")
    var waterState: String = NSLocalizedString("good", comment: "good")
    var widthPictureCell: CGFloat = 0.0
    lazy var imagePicker: UIImagePickerController = {
        let imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        return imagePicker
    }()
    
    enum ImageSource {
        case photoLibrary
        case camera
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var ble = BLESettings()
        ble.startScan()
        //print("ble listperif => \(ble.p)")
        
        
        if(self.isNotif){
            self.currentGardener = self.notifIdGardener
        }
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.backButt.isHidden = self.isNotif
        }
        setupShadow()
        self.currentUser = Auth.auth().currentUser
        if(isNotif){
            self.userRepository.getCurrentGardenerReference(for: currentUser.uid).setValue(self.notifIdGardener)
        }
        self.userCurrentGardenerRef = self.userRepository.getCurrentGardenerReference(for: currentUser.uid)
        
        let img = UIImage(named: "image0_monpotager.png")
        self.collectionViewPicture.layer.contents = img?.cgImage
        
        //self.humidityLabelTxt.adjustsFontSizeToFitWidth = true
        //self.humidityLabelTxt.minimumScaleFactor = 0.2
        
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.someAction (_:)))
        self.vCircle.addGestureRecognizer(gesture)
    }
    
    @objc func someAction(_ sender:UITapGestureRecognizer){
        if(!classic){
            printAlert()
        }
    }
    
    fileprivate func setupShadow() {
        vCircleShadow.layer.shadowColor = UIColor.black.cgColor
        vCircleShadow.layer.shadowRadius = 5
        vCircleShadow.layer.shadowOpacity = 0.3
        vCircleShadow.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.handleCurrentGardener = self.userCurrentGardenerRef.observe(.value, with: { (snapshot) in
            self.currentGardener = snapshot.value as? String
            if self.currentGardener.isEmpty {
                //                self.perform(segue: StoryboardSegue.Home.goToSubscribe)
                NotificationCenter.default.post(name: UserService.visitedUserNotification, object: nil)
            } else {
                self.currentPicture = 0
                self.gardenerRepository.getReference(for: self.currentGardener).observeSingleEvent(of: .value, with: { (snapGardener) in
                    print("OBSERVE SINGLE")
                    self.gardenerStatsTest = self.gardenerRepository.getGardenerStatsReference(for: self.currentGardener)
                
                    print("rendu --> \(snapGardener)")
                    var gardener = self.gardenerTransformer.toGardenerModel(snap: snapGardener)
                    self.checkClassicOrAgrove(gardener: gardener)
                    
                    
                    self.gardenerImagesRef = self.gardenerRepository.getMetadataImagesReference(by: self.currentGardener)
                    

                    self.gardenerTipsRef = self.gardenerRepository.getGardenerTipsReference(by: self.currentGardener)
                    
                    if (gardener.type == "parcelle") {
                        print("TAKE PARENT PARCELLE => \(gardener.id)")
                        self.gardenerRepository.getReference(for: gardener.gardenerParent).observeSingleEvent(of: .value, with: { (snapParent) in
                            var gardener = self.gardenerTransformer.toGardenerModel(snap: snapParent)
                            print("CHECK PROGRESS => \(gardener.id)")
                            self.setAllProgressGardener(gardener)
                        })
                    } else {
                        print("TAKE NOT PARCELLE => \(gardener.id)")
                        self.setAllProgressGardener(gardener)
                    }
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        if(gardener.loraTs.isEmpty) {
                            self.alertView.isHidden = true
                        }else{
                            self.alertView.isHidden = !isOlderThanTwoDays(timestamp: Int(gardener.loraTs) ?? 0)
                            self.alertLabel.text = "⚠️ Perte de connexion LoRa depuis le \(parseTimestampToDateString(timestamp: Int(gardener.loraTs) ?? 0))"
                        }
                    }
                    print("tooooooooo => \(gardener.loraTs)")
                    let pictures = gardener.metadata.images
                    self.numberOfPictures = pictures.count
                    if  self.numberOfPictures > 2 {
                        self.rightArrowButton.isHidden = true
                        self.leftArrowButton.isHidden = true
                    }
                    self.rightArrowButton.isHidden = false
                    
                    
                    self.dataSourceImages = self.collectionViewPicture.bind(to: self.gardenerImagesRef  , populateCell: { (_ collectionView, _ indexPath, _ snapPictures) -> UICollectionViewCell in
                        let cell = self.collectionViewPicture.dequeueReusableCell(withReuseIdentifier: "pictureCell", for: indexPath) as! HeaderDashboardPictureCell
                        
                            let picture = snapPictures.key
                            cell.idPicture = picture
                            cell.delegate = self
                            cell.imagePicture.sd_setImage(with: self.gardenerRepository.getGardenerImage(by: self.currentGardener, name: "\(picture).jpg"))
                            return cell
                        
                    })
                    
                    self.handleGardenersClimat = self.gardenerRepository.getClimatReference(self.currentGardener).observe(.value, with: { snap in
                        guard let climatDict = snap.value as? [String: Any] else { return }
                        let climat = self.gardenerTransformer.toGardenerClimatModel(climatDict)
                        self.tipsService.checkWeatherToTips(climatDict: climatDict as! [String: Int], gardernerId: self.currentGardener)
                    })
                    if UIDevice.current.userInterfaceIdiom != .pad{
                        self.gardenerName.text = gardener.metadata.name
                    }
                    self.getWeather.getWeatherCity(ZIP: gardener.metadata.zipCode, countryCode: gardener.metadata.countryCode ,completion: { weather in
                        guard let weather = weather, let firstWeather = weather.weather.first else { return }
                        
                        DispatchQueue.main.async {
                            //
                            //self.windNowLabel.text = "so \(weather.wind.speed) km/h"
                            if UIDevice.current.userInterfaceIdiom == .phone{
                                if (!isGardenerAgrove(gardener)) {
                                    self.cardTemperature.text = String(format: "%.f°", weather.main.temp - 273.15)
                                    self.cardAirHumidity.text = "\(weather.main.humidity) %"
                                    self.cardPressure.text = "\(Int(weather.main.pressure)) hPa"
                                    self.cardPressure.adjustsFontSizeToFitWidth = true
                                    self.luminosityIcon.isHidden = true
                                
                                    self.cardLuminosity.isHidden = true
                                    self.luminosityLabel.isHidden = true
                                    
                                }
                            }
                           
                            //self.temparatureLowLabel.text = String(format: "%.f°", weather.main.temp_min - 273.15)
                            //self.temperatureHighLabel.text = String(format: "%.f°", weather.main.temp_max - 273.15)
                        }
                    })
                    
                    
                    self.handleTips = self.gardenerTipsRef.observe(.value, with: { (snap) in
                        let value = snap.value as? [String: Bool] ?? [:]
                        var filtered = value.filter({ $0.value == true })
                        if let index = filtered.index(forKey: "temperature") {
                            filtered.remove(at: index)
                        }
                        self.arrayTips = filtered
                        if !filtered.isEmpty {
                            self.roundedAlertClimat.isHidden = false
                            self.roundedAlertStat.isHidden = false
                        } else {
                            self.roundedAlertStat.isHidden = true
                            self.roundedAlertClimat.isHidden = true
                        }
                    })
                    
                })
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let handleCurrentGardener = handleCurrentGardener {
            self.userCurrentGardenerRef.removeObserver(withHandle: handleCurrentGardener)
        }
        if let handlePictures = handlePictures {
            self.gardenerImagesRef.removeObserver(withHandle: handlePictures)
        }
        if let handleTips = self.handleTips {
            self.gardenerTipsRef.removeObserver(withHandle: handleTips)
        }
        dataSourceImages?.unbind()
    }
    
    /*override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if UIDevice.current.userInterfaceIdiom == .pad {
            widthPictureCell = self.collectionViewPicture.bounds.width * 0.5
            self.collectionViewPicture.isScrollEnabled = false
        } else {
            widthPictureCell = self.collectionViewPicture.bounds.width * 0.7
        }
        if let flowLayout = self.collectionViewPicture.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: widthPictureCell, height: self.collectionViewPicture.bounds.height)
        }
    }*/
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setAllProgressGardener(_ gardener: GardenerModel) {
        if UIDevice.current.userInterfaceIdiom != .pad {
            //self.pourcentageHumidityLabel.text = "\(gardener.stats.humidity) %"
            self.cardAirHumidity.text = "\(gardener.stats.humidity)%"
            
            //self.temparatureNowLabel.text = "\(gardener.stats.temperature) °"
            self.cardTemperature.text = "\(gardener.stats.temperature)°c"
            
            //self.lumenLabel.text = "\(gardener.stats.luminosity) Lum"
            self.cardLuminosity.text = "\(gardener.stats.luminosity) klx"
            
            self.cardPressure.text = "\(gardener.stats.pressure) hPa"
            
            self.setupStatsProgress(gardener.stats)
            print("rendu > \(gardener.stats.capacities)")
        }
    }
    
    private func selectPicture(_ index: Int, animated: Bool) {
        guard index != self.dataSourceImages.items.count else {
            self.currentPicture -= 1
            self.rightArrowButton.isHidden = true
            return
        }
        if index == 0 {
            self.rightArrowButton.isHidden = false
            self.leftArrowButton.isHidden = true
        } else if index + 1 == self.numberOfPictures - 1 {
            self.leftArrowButton.isHidden = false
            self.rightArrowButton.isHidden = true
        } else {
            self.rightArrowButton.isHidden = false
            self.leftArrowButton.isHidden = false
        }
        let indexPath = IndexPath(item: index, section: 0)
        self.collectionViewPicture.scrollToItem(at: indexPath, at: .left, animated: animated)
        self.currentPicture = index
    }
    @IBAction func irrigParametersTapped(_ sender: Any) {
        
    }
    
    @IBAction func arrowTapped(_ sender: UIButton) {
        sender.isEnabled = false
        let currentGardenerIndex = self.currentPicture!
        if sender == leftArrowButton {
            self.selectPicture(currentGardenerIndex - 1, animated: true)
        }
        if sender == rightArrowButton {
            self.selectPicture(currentGardenerIndex + 1, animated: true)
        }
        sender.isEnabled = true
    }
    
    func presentWithSource(_ source: UIImagePickerController.SourceType) {
        imagePicker.sourceType = source
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func addPictureTapped(_ sender: UIButton) {
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
    
    @IBAction func alertTipsTapped(_ sender: UIButton) {
//        if !self.arrayTips.isEmpty {
//            let controller = StoryboardScene.TasksAndTips.tipsDetailVC.instantiate()
//
//            controller.modalTransitionStyle = .crossDissolve
//            controller.modalPresentationStyle = .overFullScreen
//
//            controller.gardenerId = self.currentGardener
//            controller.nameOfAlert = arrayTips.first?.key
//
//            self.present(controller, animated: true, completion: nil)
//        } else {
//            self.popOKAlertController(title: NSLocalizedString("no_alert_for_the_moment", comment: "no_alert_for_the_moment"), message: NSLocalizedString("conditions_are_good_to_ensure_the_growth", comment: "conditions_are_good_to_ensure_the_growth"))
//        }
        printAlert()
    }
    
    private func printAlert(){
        var title = ""
        var content = ""
        
        if(waterState != NSLocalizedString("good", comment: "good") || baterryState != NSLocalizedString("good", comment: "good") || humidityState != NSLocalizedString("perfectly_humid", comment: "perfectly_humid")){
            title.append(NSLocalizedString("be_careful", comment: "Attention"))
            content.append(NSLocalizedString("it_seems_that", comment: "it_seems_that"))
            if(humidityState != NSLocalizedString("perfectly_humid", comment: "perfectly_humid")){
                content.append(" \(NSLocalizedString("your_soil_moisture_is", comment: "your_soil_moisture_is")) \(humidityState.lowercased())\n")
            }
            if(baterryState != NSLocalizedString("good", comment: "good")){
                content.append("  \(NSLocalizedString("your_battery_is", comment: "your_battery_is")) \(baterryState.lowercased())\n")
            }
            if(waterState != NSLocalizedString("good", comment: "good")) {
                content.append("  \(NSLocalizedString("your_water_level_is", comment: "your_water_level_is")) \(waterState.lowercased())\n")
            }
        }else{
            title = NSLocalizedString("congratulations", comment: "congratulations")
            content = NSLocalizedString("well_done_Aal_the_conditions_are_right_to_guarantee_the_growth_of_your_crops", comment: "well_done_Aal_the_conditions_are_right_to_guarantee_the_growth_of_your_crops")
        }
        
        self.popOKAlertController(title: title, message: content)
    }
    
    
    private func getNameOfStat(_ nameStat: String) -> String {
        switch nameStat {
        case "soilMisture":
            return NSLocalizedString("soil_misture", comment: "soil_misture")
        case "solarPower":
            return NSLocalizedString("solar_power", comment: "solar_power")
        case "battery":
            return NSLocalizedString("battery", comment: "battery")
        case "waterLevel":
            return NSLocalizedString("water_level", comment: "water_level")
        default:
            return NSLocalizedString("error", comment: "error")
        }
    }
    
    fileprivate func setupStatsProgress(_ stats: GardenerStatsModelNew) {
        
        setupGlobalProgress(stats)
        setupColorProgress(progress: self.linearProgressWater, value: Float(stats.waterLevel), name: "WATER")
        setupHumidityColorProgress(progress: self.linearProgressHumidity, value: Float(stats.capacities.c1))
        setupColorProgress(progress: self.linearProgressBattery, value: Float(stats.battery), name: "BATTERY")
        
    }
    
    fileprivate func setupColorProgress(progress: LinearProgressView, value: Float, name: String) {
        switch value {
        case 0...19:
            progress.trackColor = Styles.PlantRRedProgressBarFriend
            progress.setProgress(value, animated: true)
            if(name == "WATER"){
                labelWaterStatus.text = NSLocalizedString("bad", comment: "bad")
                waterState = NSLocalizedString("bad", comment: "bad")
            }else{
                labelBatteryStatus.text = NSLocalizedString("bad", comment: "bad")
                baterryState = NSLocalizedString("bad", comment: "bad")
            }
        case 20...39:
            progress.trackColor = Styles.PlantROrangeProgressBarFriend
            progress.setProgress(value, animated: true)
            if(name == "WATER"){
                labelWaterStatus.text = NSLocalizedString("medium", comment: "medium")
                waterState = NSLocalizedString("medium", comment: "medium")
            }else{
                labelBatteryStatus.text = NSLocalizedString("medium", comment: "medium")
                baterryState = NSLocalizedString("medium", comment: "medium")
            }
        default:
            progress.trackColor = Styles.PlantRDarkGreenProgressBar
            progress.setProgress(value, animated: true)
            if(name == "WATER"){
                labelWaterStatus.text = NSLocalizedString("good", comment: "good")
                waterState = NSLocalizedString("good", comment: "good")
            }else{
                labelBatteryStatus.text = NSLocalizedString("good", comment: "good")
                baterryState = NSLocalizedString("good", comment: "good")
            }
            
        }
    }
    
    fileprivate func setupHumidityColorProgress(progress: LinearProgressView, value: Float) {
        switch value {
        case 0...50:
            progress.trackColor = Styles.PlantRRedProgressBarFriend
            progress.setProgress(value, animated: true)
            labelHumidityStatus.text = NSLocalizedString("too_dry", comment: "too_dry")
            humidityState = NSLocalizedString("too_dry", comment: "too_dry")
        case 51...70:
            progress.trackColor = Styles.PlantROrangeProgressBarFriend
            progress.setProgress(value, animated: true)
            labelHumidityStatus.text = NSLocalizedString("slightly_humid", comment: "slightly_humid")
            humidityState = NSLocalizedString("slightly_humid", comment: "slightly_humid")
        case 71...95:
            progress.trackColor = Styles.PlantRDarkGreenProgressBar
            progress.setProgress(value, animated: true)
            labelHumidityStatus.text = NSLocalizedString("perfectly_humid", comment: "perfectly_humid")
            humidityState = NSLocalizedString("perfectly_humid", comment: "perfectly_humid")
        default:
            progress.trackColor = Styles.PlantROrangeProgressBarFriend
            progress.setProgress(value, animated: true)
            labelHumidityStatus.text = NSLocalizedString("too_humid", comment: "too_humid")
            humidityState = NSLocalizedString("too_humid", comment: "too_humid")
            
        }
    }
    
    fileprivate func setupGlobalProgress(_ stats: GardenerStatsModelNew) {
        whatShow()
        let calcule = (stats.battery/4) + (stats.waterLevel/4)
        let value:Float = (Float(calcule)/100)
        var color = -1
        if (stats.battery < 40 && stats.battery >= 20 ||
            stats.waterLevel < 40 && stats.waterLevel >= 20) {
            color = 0
        }
        if (stats.battery < 20 ||
            stats.waterLevel < 20) {
            color = 1
        }
        if (color == 0) {
            self.lGlobal.text = NSLocalizedString("medium", comment: "medium")
            vCircularGlobal.progressColor = Styles.PlantROrangeProgressBarFriend
        } else if (color == 1) {
            self.lGlobal.text = NSLocalizedString("bad", comment: "bad")
            vCircularGlobal.progressColor = Styles.PlantRRedProgressBarFriend
        } else {
            self.lGlobal.text = NSLocalizedString("good", comment: "good")
            vCircularGlobal.progressColor = Styles.PlantRDarkGreenProgressBar
        }
        vCircularGlobal.trackColor = .clear
        vCircularGlobal.setProgressWithAnimation(duration: 1.0, value: (Float(calcule)/100))
    }
    
    fileprivate func whatShow() {
        self.activityIndicator.stopAnimating()
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.showIpad()
        } else {
            self.showIphone()
        }
    }
    
    fileprivate func showIpad() {
        self.vCircle.isHidden = false
        self.contentIpad.isHidden = false
        self.contentTips.isHidden = false
    }
    
    fileprivate func showIphone() {
        self.vCircle.isHidden = false
    }
    
    fileprivate func checkClassicOrAgrove(gardener: GardenerModel) {
        setImageGenericGardenerGreen(gardener: gardener, ivCenter: self.ivCircle)
        var isClassic = gardener.id.contains(GardenerConsts.PrefixClassic) == true
        if UIDevice.current.userInterfaceIdiom != .pad {
            if(gardener.type != "cle_en_main"){
                self.waterLvlTitle.isHidden = true
                self.waterLvlCard.isHidden = true
                self.irrigButton.isHidden = false
            }
        }
        if UIDevice.current.userInterfaceIdiom != .pad{
            self.irrigButton.isHidden = gardener.type != "cle_en_main"
        }
        
        if isClassic {
            self.classic = true
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.svIpadProgressBottom.isHidden = true
                self.vCircularGlobal.isHidden = true
                self.lGlobal.isHidden = true
                self.climatTitle.text = NSLocalizedString("climate_data_from_weather", comment: "climate_data_from_weather")
//                self.contentsIphone.isHidden = true
//                self.contentTips.isHidden = true
//                self.cardGarden.isHidden = false
            } else {
                self.svIphoneProgressBottom.isHidden = true
                self.lGlobal.isHidden = true
                self.vCircularGlobal.isHidden = true
                self.climatTitle.text = NSLocalizedString("climate_data_from_weather", comment: "climate_data_from_weather")
                self.contentsIphone.isHidden = true
                self.contentTips.isHidden = true
                self.cardGarden.isHidden = false
            }
        } else {
            self.classic = false
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.svIpadProgressBottom.isHidden = false
                self.vCircularGlobal.isHidden = false
                self.lGlobal.isHidden = false
                //TODO: bug pad
                //self.cardGarden.isHidden = false
                //self.climatTitle.text = NSLocalizedString("climate_data_from_my_garden", comment: "climate_data_from_my_garden")
                //self.contentsIphone.isHidden = false
                self.contentTips.isHidden = false
            } else {
                self.svIphoneProgressBottom.isHidden = false
                self.vCircularGlobal.isHidden = false
                self.lGlobal.isHidden = false
                //self.cardGarden.isHidden = false
                self.climatTitle.text = NSLocalizedString("climate_data_from_my_garden", comment: "climate_data_from_my_garden")
                //self.contentsIphone.isHidden = false
                self.contentTips.isHidden = false
            }
        }
    }
}

extension PlantRVC: HeaderDashboardPictureCellDelegate {
    func didDeletePicture(named: String) {
        let alerteActionSheet = UIAlertController(title: nil, message: NSLocalizedString("do_you_really_want_to_delete_this_picture", comment: "do_you_really_want_to_delete_this_picture"), preferredStyle: .alert)
        
        alerteActionSheet.view.tintColor = Styles.PlantRBlackColor
        
        let delete = UIAlertAction(title: NSLocalizedString("delete", comment: "delete"), style: .default) { _ in
            
            let pictureToRemove = self.gardenerImagesRef.child(named)
            
            
            if self.dataSourceImages.items.count == 3 {
                self.leftArrowButton.isHidden = true
                self.rightArrowButton.isHidden = true
            }
            pictureToRemove.removeValue()
        }
        let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: nil)
        alerteActionSheet.addAction(delete)
        alerteActionSheet.addAction(cancel)
        
        present(alerteActionSheet, animated: true, completion: nil)
    }
    
}

extension PlantRVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originale = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            guard let data = originale.jpegData(compressionQuality: 0.1) else { return }
            let imageRef = self.gardenerImagesRef.childByAutoId()
            
            self.gardenerRepository.getStorageGardenerPicturesRef(by: currentGardener!).child("\(imageRef.key!).jpg").putData(data, metadata: nil, completion: { [self] (metadata, error) in
                if error != nil { return }
                gardenerRepository.getRootReference().child(currentGardener).child("metadata").child("images").removeValue()
                imageRef.setValue(true)
            })
        }
        dismiss(animated: true, completion: nil)
    }
}
