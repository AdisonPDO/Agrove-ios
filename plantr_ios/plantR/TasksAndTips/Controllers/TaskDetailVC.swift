//
//  TaskDetailVC.swift
//  plantR_ios
//
//  Created by Rabissoni on 29/03/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase
import FirebaseMessaging

class TaskDetailVC: UIViewController {
    
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!
    var userRepository: UserRepository!
    var userTransformer: UserTransformer!
    var plantRepository: PlantRepository!
    var plantsService: PlantsService!
    
    @IBOutlet var pictureTask: UIImageView!
    @IBOutlet var nameTask: UILabel!
    @IBOutlet var descriptionTask: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var ivNextButton: UIImageView!
    @IBOutlet weak var ivLike: UIImageView!
    @IBOutlet weak var labelButton: UILabel!
    @IBOutlet weak var lPlantType: UILabel!
    
    
    var gardenerId: String?
    var plantUID: String?
    var taskModel: GardenerTaskModelToAllTasks?
    var toDo: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let taskModel = taskModel, let plantUID = plantUID, let todo = toDo else { return }
        self.nameTask.text = taskModel.task.title
        self.descriptionTask.text = taskModel.task.description
        self.lPlantType.text = plantsService.plants[taskModel.plantId]?.infoPlant.name ?? ""
        let taskPicture = self.plantRepository.getTaskPictureStorageReference(for: plantUID, name: taskModel.task.title)
        self.pictureTask.sd_setImage(with: taskPicture)
        if (!todo) {
            nextButton.isEnabled = false
            nextButton.isHidden = true
            ivLike.isHidden = true
            ivNextButton.isHidden = true
            labelButton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func itsGoodTapped(_ sender: Any) {
        
        let alertController = UIAlertController(title: "\(NSLocalizedString("did_you_complete_the_mission", comment: "did_you_complete_the_mission")) \(taskModel?.task.title ?? "") ?", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: "yes"), style: .default, handler: { _ in
            self.actionDone()
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("not_yet", comment: "not yet"), style: .cancel, handler: nil))
        alertController.view.tintColor = Styles.PlantRMainGreen
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    fileprivate func actionDone() {
        guard let gardenerId = self.gardenerId, let taskModel = taskModel, let plantUID = plantUID else { return }
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
                            self.popOKAlertController(title: NSLocalizedString("task_completed", comment: "task_completed"), message: nil, okHandler: { (_ s) in
                                Messaging.messaging().subscribe(toTopic: gardenerId)
                                self.dismiss(animated: true, completion: nil)
                            })
                        }
                        })
                    }
            })
        })
        
    }
}
