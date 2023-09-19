//
//  TaskDetailNotifcation.swift
//  plantR_ios
//
//  Created by Boris Roussel on 27/11/2020.
//  Copyright © 2020 Agrove. All rights reserved.
//

import UIKit
import FirebaseUI

class TaskDetailNotificationVC: UIViewController {
    
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!
    var userRepository: UserRepository!
    var userTransformer: UserTransformer!
    var plantRepository: PlantRepository!
    
    @IBOutlet var pictureTask: UIImageView!
    @IBOutlet var nameTask: UILabel!
    @IBOutlet var descriptionTask: UILabel!
    @IBOutlet weak var lPlantType: UILabel!
    @IBOutlet weak var lDoneBy: UILabel!
    
    var gardenerId: String?
    var plantUID: String?
    var taskName: String?
    var stage: String?
    var taskId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ARRIVED")
        
        guard let plantUID = plantUID, let gardernerId = gardenerId, let taskName = taskName, let stage = stage, let taskId = taskId else {
            print("OUT")
            return
        }
    
        
        self.gardenerRepository.getPlantStageAndRowReference(by: gardernerId, by: stage).observeSingleEvent(of: .value, with: { (snapPlant) in
            print("A")
            let value = snapPlant.value as! [String: Any]
            print(value)
            var allTask = self.gardenerTransformer.toAllTasksWithOnePlant(value, stageAndRow: stage)
            print(allTask)
            var task = allTask.filter({ $0.task.taskId == taskId }).first
            print(task)
            if let taskNotNull = task {
                if let doneBy = taskNotNull.task.doneBy {
                    self.userRepository.getMetadataReference(for: doneBy.userId).observeSingleEvent(of: .value, with: { snapUser in
                        guard let dictUser = snapUser.value as? [String: Any] else { return }

                        let user = self.userTransformer.toUserMetadataModel(dictUser)

                        self.lDoneBy.isHidden = false
                        self.lDoneBy.text = "\(NSLocalizedString("mission_carried_out_by", comment: "mission_carried_out_by")) \(user.firstName) \(user.lastName) \(NSLocalizedString("at", comment: "at")) \(doneBy.date.shortDate)"
                    })
                } else {
                    self.lDoneBy.isHidden = true
                }
                self.nameTask.text = taskNotNull.task.title
                self.descriptionTask.text = taskNotNull.task.description
                
                self.plantRepository.getPlantNameReference(for: plantUID).observeSingleEvent(of: .value, with: { (snapName) in
                    self.lPlantType.text = snapName.value as? String ?? ""
                })
                let taskPicture = self.plantRepository.getTaskPictureStorageReference(for: plantUID, name: taskNotNull.task.title)
                self.pictureTask.sd_setImage(with: taskPicture)
            }
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
