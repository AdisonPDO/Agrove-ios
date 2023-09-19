//
//  NewTaskDetailVC.swift
//  plantR_ios
//
//  Created by Boris Roussel on 20/04/2021.
//  Copyright © 2021 Agrove. All rights reserved.
//

import UIKit
import youtube_ios_player_helper
import Firebase
import FirebaseMessaging

private enum ToolsConst {
    static let Gants = "gants"
    static let Pelle = "pelle"
    static let Arrosoir = "arrosoir"
    static let Binette = "binette"
    static let Ficelle = "ficelle"
    static let Rateau = "rateau"
    static let Secateur = "secateur"
    static let Semoir = "semoir"
    static let Tuteur = "tuteur"
    static let Eau = "eau"
    static let Fertilisant = "fertilisant"
    static let Godets = "godets"
    static let Transplantoir = "transplantoir"
    static let Paille = "paille"
    static let Pinceau = "pinceau"
    static let Ciseaux = "ciseaux"
    static let Couteau = "couteau"
    static let Pulverisateur = "pulverisateur"
    static let Verre = "verre"
    static let Savon = "savon"
    static let Bicarbonate = "bicarbonate"
    static let VoileHivernage = "voile_dhivernage"
    
}

class NewTaskDetailVC: UIViewController {
    
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!
    var userRepository: UserRepository!
    var userTransformer: UserTransformer!
    var plantRepository: PlantRepository!
    var plantsService: PlantsService!
    
    var plantUID: String?
    var gardener: GardenerModel?
    var taskModel: GardenerTaskModelToAllTasks?
    var notification: Bool?
    
    var gardenerId: String?
    var taskName: String?
    var stage: String?
    var taskId: String?
    
    @IBOutlet var lPlantName: UILabel!
    @IBOutlet var lNameTask: UILabel!
    @IBOutlet var lStage: UILabel!
    @IBOutlet var lPosition: UILabel!
    @IBOutlet var ivPlant: UIImageView!
    @IBOutlet var ivStage: UIImageView!
    @IBOutlet var ytPlayer: YTPlayerView!
    @IBOutlet var lDoneBy: UILabel!
    @IBOutlet var lUserName: UILabel!
    @IBOutlet var ivUserDone: UIImageView!
    @IBOutlet var taskDescritpionL: UILabel!
    
    @IBOutlet var arrIV: [UIImageView]!
    @IBOutlet var lDoInTime: UILabel!
    @IBOutlet var ivPriority: UIImageView!
    @IBOutlet var lPriority: UILabel!
    @IBOutlet var tvSteps: UITableView!
    @IBOutlet var svDoneBy: UIStackView!
    @IBOutlet var vContentHeader: UIView!
    @IBOutlet var cTVBottom: NSLayoutConstraint!
    @IBOutlet var vBottom: UIView!
    @IBOutlet var ivPlacements: [UIImageView]!
    
    @IBOutlet var LMyMissions: UILabel!
    @IBOutlet var LTools: UILabel!
    @IBOutlet var LDuration: UILabel!
    @IBOutlet var LImportance: UILabel!
    @IBOutlet var LHowToDo: UILabel!
    @IBOutlet var LDoneButt: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.translate()
        self.setupInformations()
//        self.taskDescritpionL.adjustsFontSizeToFitWidth = true
//        self.taskDescritpionL.minimumScaleFactor = 0.5
//        self.taskDescritpionL.sizeToFit()
    }
    
    private func translate(){
        self.LMyMissions.text = NSLocalizedString("my_missions", comment: "my missions")
        self.LTools.text = NSLocalizedString("tools", comment: "tools")
        self.LDuration.text = NSLocalizedString("duration", comment: "duration")
        self.LImportance.text = NSLocalizedString("importance", comment: "importance")
        self.LHowToDo.text = NSLocalizedString("how_to_do", comment: "how to do")
        self.LDoneButt.setTitle(NSLocalizedString("done", comment: "done"), for: .normal)
    }
    
    fileprivate func popUpOnScreenComplete(gardenerId: String) {
        self.popOKAlertController(title: NSLocalizedString("task_completed", comment: "task_completed"), message: nil, okHandler: { (_ ) in
            Messaging.messaging().subscribe(toTopic: gardenerId)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    fileprivate func setupInformations() {
        guard let isNotification = notification else { return }
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            self.vContentHeader.frame.size.height = 670
            self.vContentHeader.layoutIfNeeded()
        }
        if (isNotification) {
            self.setupWithNotification()
        } else {
            self.setupWithoutNotification()
        }
    }
    fileprivate func setupTools(_ taskModel: GardenerTaskModelToAllTasks) {
        taskModel.task.tools.enumerated().forEach { index, nameTool in
            setImageTools(index: index, toolName: nameTool)
        }
    }
    fileprivate func setupStage(_ taskModel: GardenerTaskModelToAllTasks) {
        guard let gardener = gardener else { return }
        print("START SetupStage")
        /* RAJOUTER VARIABLE POUR LE NOMBRE DE PLANTE DANS UN ETAGE */
        let nbMaxStage = Int(gardener.stage) ?? 4
        let nbRangs = Int(gardener.rangs) ?? 0
        let nbMaxRow = Int(gardener.stage) ?? 4
        
        let stagePlacement = Int(taskModel.stageAndRow[0]) ?? 4
        let rowPlacement = (Int(taskModel.stageAndRow[2]) ?? 3) + 1
        
        switch gardener.type {
        case "pot":
            self.lStage.text = gardener.metadata.name
            self.lPosition.isHidden = true
            setImageGenericGardenerGreen(gardener: gardener, ivCenter: self.ivStage)
        case "capteur_pot":
            self.lStage.text = gardener.metadata.name
            self.lPosition.isHidden = true
            setImageGenericGardenerGreen(gardener: gardener, ivCenter: self.ivStage)
        case "carre":
            self.lStage.text = "\(NSLocalizedString("row", comment: "row")) \(nbMaxStage - stagePlacement)"
            setImagePlacement(maxRow: nbMaxRow, row: rowPlacement)
            self.lPosition.text = "\(NSLocalizedString("location", comment: "location")) \(rowPlacement)"
            let rang = setSquareRowDimension(dimension: gardener.dimension)
            let placement = (Int(String(taskModel.stageAndRow.last ?? "0")) ?? 0) + 1
            self.ivStage.image = UIImage(named: "rang\(rang)-\(nbMaxStage - stagePlacement)")
            print("test => rang\(rang)-\(placement) - roooow -> ")
        case "jardiniere":
            self.lStage.text = gardener.metadata.name
            setImagePlacement(maxRow: setJardiniereRowDimension(dimension: gardener.dimension), row: rowPlacement)
            self.lPosition.text = "\(NSLocalizedString("location", comment: "location")) \(rowPlacement)"
            setImageGenericGardenerGreen(gardener: gardener, ivCenter: self.ivStage)
        case "capteur_jardiniere":
            self.lStage.text = gardener.metadata.name
            setImagePlacement(maxRow: nbMaxRow, row: rowPlacement)
            self.lPosition.text = "\(NSLocalizedString("location", comment: "location")) \(rowPlacement)"
            setImageGenericGardenerGreen(gardener: gardener, ivCenter: self.ivStage)
        case "cle_en_main":
            self.lStage.text = "\(NSLocalizedString("level", comment: "level")) \(nbMaxStage - stagePlacement)"
            setImagePlacement(maxRow: nbMaxRow, row: rowPlacement)
            self.lPosition.text = "\(NSLocalizedString("location", comment: "location")) \(rowPlacement)"
            switch (taskModel.stageAndRow.first) {
            case "0":
                self.ivStage.image = UIImage(named: "etage\(gardener.stage)4")
            case "1":
                self.ivStage.image = UIImage(named: "etage\(gardener.stage)3")
            case "2":
                self.ivStage.image = UIImage(named: "etage\(gardener.stage)2")
            case "3":
                self.ivStage.image = UIImage(named: "etage\(gardener.stage)1")
            default:
                self.ivStage.image = UIImage(named: "etage\(gardener.stage)4")
            }
        case "mural":
            self.lStage.text = "\(NSLocalizedString("level", comment: "level")) \(nbMaxStage - stagePlacement)"
            setImagePlacement(maxRow: nbMaxRow, row: rowPlacement)
            self.lPosition.text = "\(NSLocalizedString("location", comment: "location")) \(rowPlacement)"
        default:
            setupStageNext(gardener, taskModel)
        }
    }
    
    @IBAction func ibBack(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionDone(_ sender: UIButton) {
        actionDone()
    }
    
    fileprivate func setImagePlacement(maxRow: Int, row: Int) {
        switch maxRow {
        case 1:
            self.ivPlacements[0].isHidden = false
            self.ivPlacements[1].isHidden = true
            self.ivPlacements[2].isHidden = true
            self.ivPlacements[3].isHidden = true
        case 2:
            self.ivPlacements[0].isHidden = false
            self.ivPlacements[1].isHidden = false
            self.ivPlacements[2].isHidden = true
            self.ivPlacements[3].isHidden = true
        case 3:
            self.ivPlacements[0].isHidden = false
            self.ivPlacements[1].isHidden = false
            self.ivPlacements[2].isHidden = false
            self.ivPlacements[3].isHidden = true
        case 4:
            self.ivPlacements[0].isHidden = false
            self.ivPlacements[1].isHidden = false
            self.ivPlacements[2].isHidden = false
            self.ivPlacements[3].isHidden = false
        default:
            break
        }
        switch row {
        case 1:
            self.ivPlacements[0].image = UIImage(named: "pastilleVert")
            self.ivPlacements[1].image = UIImage(named: "pastilleGrisOccupation")
            self.ivPlacements[2].image = UIImage(named: "pastilleGrisOccupation")
            self.ivPlacements[3].image = UIImage(named: "pastilleGrisOccupation")
        case 2:
            self.ivPlacements[0].image = UIImage(named: "pastilleGrisOccupation")
            self.ivPlacements[1].image = UIImage(named: "pastilleVert")
            self.ivPlacements[2].image = UIImage(named: "pastilleGrisOccupation")
            self.ivPlacements[3].image = UIImage(named: "pastilleGrisOccupation")
        case 3:
            self.ivPlacements[0].image = UIImage(named: "pastilleGrisOccupation")
            self.ivPlacements[1].image = UIImage(named: "pastilleGrisOccupation")
            self.ivPlacements[2].image = UIImage(named: "pastilleVert")
            self.ivPlacements[3].image = UIImage(named: "pastilleGrisOccupation")
        case 4:
            self.ivPlacements[0].image = UIImage(named: "pastilleGrisOccupation")
            self.ivPlacements[1].image = UIImage(named: "pastilleGrisOccupation")
            self.ivPlacements[2].image = UIImage(named: "pastilleGrisOccupation")
            self.ivPlacements[3].image = UIImage(named: "pastilleVert")
        default:
            self.ivPlacements[0].image = UIImage(named: "pastilleVert")
            self.ivPlacements[1].image = UIImage(named: "pastilleGrisOccupation")
            self.ivPlacements[2].image = UIImage(named: "pastilleGrisOccupation")
            self.ivPlacements[3].image = UIImage(named: "pastilleGrisOccupation")
        }
    }
    
    fileprivate func setImageTools(index: Int, toolName: String) {
        switch toolName {
        case ToolsConst.Gants:
            self.arrIV[index].image = UIImage(named: ToolsConst.Gants)
        case ToolsConst.Pelle:
            self.arrIV[index].image = UIImage(named: ToolsConst.Pelle)
        case ToolsConst.Arrosoir:
            self.arrIV[index].image = UIImage(named: ToolsConst.Arrosoir)
        case ToolsConst.Binette:
            self.arrIV[index].image = UIImage(named: ToolsConst.Binette)
        case ToolsConst.Ficelle:
            self.arrIV[index].image = UIImage(named: ToolsConst.Ficelle)
        case ToolsConst.Rateau:
            self.arrIV[index].image = UIImage(named: ToolsConst.Rateau)
        case ToolsConst.Secateur:
            self.arrIV[index].image = UIImage(named: ToolsConst.Secateur)
        case ToolsConst.Semoir:
            self.arrIV[index].image = UIImage(named: ToolsConst.Semoir)
        case ToolsConst.Tuteur:
            self.arrIV[index].image = UIImage(named: ToolsConst.Tuteur)
        case ToolsConst.Eau:
            self.arrIV[index].image = UIImage(named: ToolsConst.Eau)
        default:
            self.setImageToolsSuite(index: index, toolName: toolName)
        }
        self.arrIV[index].isHidden = false
    }
    fileprivate func setImageToolsSuite(index: Int, toolName: String) {
        switch toolName {
        case ToolsConst.Fertilisant:
            self.arrIV[index].image = UIImage(named: ToolsConst.Fertilisant)
        case ToolsConst.Couteau:
            self.arrIV[index].image = UIImage(named: ToolsConst.Couteau)
        case ToolsConst.Pinceau:
            self.arrIV[index].image = UIImage(named: ToolsConst.Pinceau)
        case ToolsConst.Verre:
            self.arrIV[index].image = UIImage(named: ToolsConst.Verre)
        case ToolsConst.Transplantoir:
            self.arrIV[index].image = UIImage(named: ToolsConst.Transplantoir)
        case ToolsConst.Pulverisateur:
            self.arrIV[index].image = UIImage(named: ToolsConst.Pulverisateur)
        case ToolsConst.Bicarbonate:
            self.arrIV[index].image = UIImage(named: ToolsConst.Bicarbonate)
        case ToolsConst.Paille:
            self.arrIV[index].image = UIImage(named: ToolsConst.Paille)
        case ToolsConst.Ciseaux:
            self.arrIV[index].image = UIImage(named: ToolsConst.Ciseaux)
        case ToolsConst.Godets:
            self.arrIV[index].image = UIImage(named: ToolsConst.Godets)
        case ToolsConst.Semoir:
            self.arrIV[index].image = UIImage(named: ToolsConst.Semoir)
        case ToolsConst.VoileHivernage:
            self.arrIV[index].image = UIImage(named: ToolsConst.VoileHivernage)
        default:
            self.arrIV[index].image = UIImage(named: "")
        }
    }
    
    fileprivate func setupWithoutNotification() {
        guard let taskModel = taskModel, let plantUID = plantUID, let gardener = gardener else {
            self.tvSteps.reloadData()
            self.tvSteps.layoutTableHeaderView()
            return
            
        }
        self.setupTools(taskModel)
        self.setupStage(taskModel)
        self.lPlantName.text = plantsService.plants[taskModel.plantId]?.infoPlant.name ?? " "
        self.lNameTask.text = UtilsCategories().getTaskNameTrad(str: taskModel.task.title)
        print("tototototot \(taskModel.task.description == " ")")
        if(!taskModel.task.description.isEmpty && taskModel.task.description != " "){
            self.taskDescritpionL.text = taskModel.task.description
        }
        
        print("totototo -> \(taskModel.task)")
        self.ivPlant.sd_setImage(with: self.gardenerRepository.getGardenerPlantStageAndRowStorage(by: gardener.id, by: taskModel.stageAndRow))
        if taskModel.picture == false {
            if let imagePlant = plantsService.plants[plantUID]?.imagePlant {
                self.ivPlant.sd_setImage(with: imagePlant)
            }
        } else {
            let image = self.gardenerRepository.getGardenerPlantStageAndRowStorage(by: gardener.id, by: taskModel.stageAndRow)
            self.ivPlant.sd_setImage(with: image)
        }
        
        switch taskModel.task.priority {
        case 1:
            self.lPriority.text = NSLocalizedString("highly_recommended", comment: "highly_recommended")
            self.ivPriority.isHidden = false
        default:
            self.lPriority.text = NSLocalizedString("recommended", comment: "recommended")
            self.ivPriority.isHidden = true
        }
        self.lDoInTime.text = taskModel.task.doInTime
        if taskModel.task.url.isEmpty {
            self.ytPlayer.isHidden = true
        } else {
            self.ytPlayer.isHidden = false
            self.ytPlayer.load(withVideoId: taskModel.task.url)
        }
        if let doneBy = taskModel.task.doneBy {
            self.svDoneBy.isHidden = false
            self.vBottom.isHidden = true
            self.cTVBottom.constant = 0.0
            self.tvSteps.updateConstraints()
            self.userRepository.getMetadataReference(for: doneBy.userId).observeSingleEvent(of: .value, with: { snapUser in
                guard let dictUser = snapUser.value as? [String: Any] else { return }
                
                let user = self.userTransformer.toUserMetadataModel(dictUser)
                self.lDoneBy.text = "\(NSLocalizedString("realized_on", comment: "realized_on")) \(doneBy.date.shortDate) \(NSLocalizedString("by", comment: "by")) :"
                self.lUserName.text = "\(user.firstName) \(user.lastName)"
                self.ivUserDone.sd_setImage(with: self.userRepository.getImageProfile(for: doneBy.userId))
            })
        } else {
            self.svDoneBy.isHidden = true
            self.vBottom.isHidden = false
            self.cTVBottom.constant = 120.0
            self.tvSteps.updateConstraints()
        }
        self.tvSteps.reloadData()
        self.tvSteps.layoutTableHeaderView()
    }
    
    fileprivate func setupWithNotification() {
        guard let plantUID = plantUID, let gardernerId = gardenerId, let taskName = taskName, let stage = stage, let taskId = taskId else {
            return
        }
        
        self.gardenerRepository.getReference(for: gardernerId).observeSingleEvent(of: .value, with: { (snap) in
            self.gardener = self.gardenerTransformer.toGardenerModel(snap: snap)
            self.gardenerRepository.getPlantStageAndRowReference(by: gardernerId, by: stage).observeSingleEvent(of: .value, with: { (snapPlant) in
                let value = snapPlant.value as! [String: Any]
                var allTask = self.gardenerTransformer.toAllTasksWithOnePlant(value, stageAndRow: stage)
                var task = allTask.filter({ $0.task.taskId == taskId }).first
                if let taskModel = task {
                    self.taskModel = taskModel
                    self.setupTools(taskModel)
                    self.setupStage(taskModel)
                    self.lPlantName.text = self.plantsService.plants[taskModel.plantId]?.infoPlant.name ?? NSLocalizedString("empty", comment: "empty")
                    self.lNameTask.text = taskModel.task.title
                    self.taskDescritpionL.text = taskModel.task.description
                    
                    self.ivPlant.sd_setImage(with: self.gardenerRepository.getGardenerPlantStageAndRowStorage(by: gardernerId, by: taskModel.stageAndRow))
                    if taskModel.picture == false {
                        if let imagePlant = self.plantsService.plants[plantUID]?.imagePlant {
                            self.ivPlant.sd_setImage(with: imagePlant)
                        }
                    } else {
                        let image = self.gardenerRepository.getGardenerPlantStageAndRowStorage(by: gardernerId, by: taskModel.stageAndRow)
                        self.ivPlant.sd_setImage(with: image)
                    }
                    
                    switch taskModel.task.priority {
                    case 1:
                        self.ivPriority.isHidden = false
                    default:
                        self.ivPriority.isHidden = true
                    }
                    
                    self.lDoInTime.text = taskModel.task.doInTime
                    self.ytPlayer.load(withVideoId: taskModel.task.url)
                    if let doneBy = taskModel.task.doneBy {
                        self.svDoneBy.isHidden = false
                        self.vBottom.isHidden = true
                        self.cTVBottom.constant = 0.0
                        self.tvSteps.updateConstraints()
                        self.userRepository.getMetadataReference(for: doneBy.userId).observeSingleEvent(of: .value, with: { snapUser in
                            guard let dictUser = snapUser.value as? [String: Any] else { return }
                            
                            let user = self.userTransformer.toUserMetadataModel(dictUser)
                            self.lDoneBy.text = "\(NSLocalizedString("realized_on", comment: "realized_on")) \(doneBy.date.shortDate) \(NSLocalizedString("by", comment: "by")):"
                            self.lUserName.text = "\(user.firstName) \(user.lastName)"
                            self.ivUserDone.sd_setImage(with: self.userRepository.getImageProfile(for: doneBy.userId))
                        })
                    } else {
                        self.svDoneBy.isHidden = true
                        self.vBottom.isHidden = false
                        self.cTVBottom.constant = 120.0
                        self.tvSteps.updateConstraints()
                    }
                    
                    self.tvSteps.reloadData()
                    self.tvSteps.layoutTableHeaderView()
                }
            })
        })
    }
}
    
    
extension NewTaskDetailVC {
    func setupStageNext(_ gardener: GardenerModel,_ taskModel: GardenerTaskModelToAllTasks) {
        print("setupStageNext")
        /* RAJOUTER VARIABLE POUR LE NOMBRE DE PLANTE DANS UN ETAGE */
        let nbMaxStage = Int(gardener.stage) ?? 4
        let nbRangs = Int(gardener.rangs)
        let nbMaxRow = Int(gardener.stage) ?? 4
        let stagePlacement = Int(taskModel.stageAndRow[0]) ?? 4
        let rowPlacement = (Int(taskModel.stageAndRow[2]) ?? 3) + 1
        switch gardener.type {
        case "parcelle":
            let maxStage = (Int(gardener.stage) ?? 4) - 1
            if (0...maxStage).contains(stagePlacement) {
                self.lStage.text = "\(NSLocalizedString("level", comment: "level")) \(nbMaxStage - stagePlacement)"
                setupRangOrStage(stage:true, nbMaxStage - stagePlacement)
            } else {
                self.lStage.text = "\(NSLocalizedString("row", comment: "row")) \((nbMaxStage + nbRangs) - stagePlacement)"
                print("VALUE STAGEPLACEMENT => \( (nbMaxStage + nbRangs) - stagePlacement)")
                print(nbMaxStage)
                print(nbRangs)
                print(stagePlacement)
                print("____")
                setupRangOrStage(stage:false, (nbMaxStage + nbRangs) - stagePlacement)
            }
            setImagePlacement(maxRow: nbMaxRow, row: rowPlacement)
            self.lPosition.text = "\(NSLocalizedString("location", comment: "location")) \(rowPlacement)"
        default:
            self.lStage.text = "\(NSLocalizedString("level", comment: "level")) \(nbMaxStage - stagePlacement)"
            self.setImagePlacement(maxRow: nbMaxRow, row: rowPlacement)
            self.lPosition.text = "\(NSLocalizedString("location", comment: "location")) \(rowPlacement)"
        }
    }
    func setupRangOrStage(stage: Bool,_ stagePlacement: Int) {
        guard let gardener = gardener else { return }
        if (stage) {
            self.ivStage.image = UIImage(named: "etage\(gardener.stage)\(stagePlacement)")
        } else {
            switch stagePlacement {
            case 2:
                self.ivStage.image = UIImage(named: "rang\(gardener.rangs)-1")
            case 1:
                self.ivStage.image = UIImage(named: "rang\(gardener.rangs)-2")
            default:
                self.ivStage.image = UIImage(named: "rang\(gardener.rangs)-1")
            }
        }
    }
}

extension NewTaskDetailVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskModel?.task.steps.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stepTaskCell", for: indexPath) as! StepTaskCell
        cell.lStep.text = taskModel?.task.steps[indexPath.row].title ?? ""
        if let plantId = taskModel?.plantId, let image = taskModel?.task.steps[indexPath.row].image {
            
            print(plantId)
            print(image)
            if (image.trimmingLeadingAndTrailingSpaces().isEmpty) {
                cell.ivStep.isHidden = true
            } else {
                let refImage = self.gardenerRepository.getStorageStepTask(plantId, image)
                print(refImage)
                cell.ivStep.sd_setImage(with: refImage)
            }
            
        }
        cell.lStepInfo.text = taskModel?.task.steps[indexPath.row].description ?? ""
        return cell
    }
}

extension NewTaskDetailVC {
    fileprivate func actionDone() {
        
        guard let isNotification = self.notification, let gardenerId = isNotification ? self.gardenerId : self.gardener?.id, let taskModel = taskModel, let plantUID = plantUID else { return }
        Messaging.messaging().unsubscribe(fromTopic: gardenerId)
        self.gardenerRepository.getMetadataReference(for: gardenerId).observeSingleEvent(of: .value, with: { snap in
            guard let dict = snap.value as? [String: Any] else { return }
            let gardener = self.gardenerTransformer.toGardenerMetadataModel(dict)
            
            self.userRepository.getMetadataReference(for: Auth.auth().currentUser?.uid ?? "").observeSingleEvent(of: .value, with: { snapUser in
                guard let dictUser = snapUser.value as? [String: Any] else { return }
                
                let user = self.userTransformer.toUserMetadataModel(dictUser)
                
                let taskRef = self.gardenerRepository.getPlantStageAndRowTaskDoneInTimeReference(by: gardenerId, by: taskModel.stageAndRow, id: String(taskModel.id))
                let dateTask = Calendar.current.startOfDay(for: taskModel.task.date)
                let today = Calendar.current.startOfDay(for: Date())
                let value = Calendar.current.isDate(taskModel.task.date, inSameDayAs: today)
                taskRef.setValue(value) { [self] (error, _) in
                    if let error = error {
                        print(error)
                        return
                    }
                    self.gardenerRepository.getPlantStageAndRowTaskDoneReference(by: gardenerId, by: taskModel.stageAndRow, id: String(taskModel.id)).setValue(true)
                    self.gardenerRepository.getPlantStageAndRowTaskSetDoneByReference(by: gardenerId, by: taskModel.stageAndRow, id: String(taskModel.id)).setValue(self.gardenerTransformer.toTaskDoneDictonary(TaskDoneBy(userId: Auth.auth().currentUser?.uid ?? "", date: Date())))
                    
                    let sender = PushNotificationSender()
                    var stageKey = taskModel.stageAndRow
                    let pushTask = PushTask(title: NSLocalizedString("task_completed", comment: "task_completed"), body: "\(NSLocalizedString("the_mission", comment: "the_mission")) \"\(taskModel.task.title)\" \(NSLocalizedString("was_carried_out_by", comment: "was_carried_out_by")) \(user.firstName) \(user.lastName) \(NSLocalizedString("on_the_plant", comment: "on_the_plant")) \(plantsService.plants[taskModel.plantId]?.infoPlant.name ?? "") \(NSLocalizedString("of_the_planter", comment: "of_the_planter")) \(gardener.name)", userId: Auth.auth().currentUser?.uid ?? "", plantUID: plantUID, gardenerId: gardenerId, stage: stageKey, taskName: taskModel.task.title, taskId: taskModel.task.taskId ?? "")
                    
        
                    sender.sendPushTaskNotification(to: gardenerId, pushTask: pushTask, completion: { () in
                        DispatchQueue.main.async {
                            self.popUpOnScreenComplete(gardenerId: gardenerId)
                        }
                    })
                }
                
            })
        })
        
    }
}
