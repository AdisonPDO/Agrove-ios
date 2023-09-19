//
//  TaskDetailVC.swift
//  plantR_ios
//
//  Created by Rabissoni on 29/03/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit
import FirebaseUI

class TaskDetailDoneVC: UIViewController {
    
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
    var taskModel: GardenerTaskModelToAllTasks?
    var toDo: Bool?
    var plantsService: PlantsService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let taskModel = taskModel, let plantUID = plantUID, let todo = toDo else { return }
        if let doneBy = taskModel.task.doneBy {
            self.userRepository.getMetadataReference(for: doneBy.userId).observeSingleEvent(of: .value, with: { snapUser in
                guard let dictUser = snapUser.value as? [String: Any] else { return }
            
                let user = self.userTransformer.toUserMetadataModel(dictUser)

                self.lDoneBy.isHidden = false
                self.lDoneBy.text = "\(NSLocalizedString("mission_carried_out_by", comment: "mission_carried_out_by")) \(user.firstName) \(user.lastName) \(NSLocalizedString("at", comment: "at")) \(doneBy.date.shortDate)"
            })
        } else {
            lDoneBy.isHidden = true
        }
        self.nameTask.text = taskModel.task.title
        self.descriptionTask.text = taskModel.task.description
        self.lPlantType.text = plantsService.plants[taskModel.plantId]?.infoPlant.name ?? ""

        let taskPicture = self.plantRepository.getTaskPictureStorageReference(for: plantUID, name: taskModel.task.title)
        self.pictureTask.sd_setImage(with: taskPicture)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
