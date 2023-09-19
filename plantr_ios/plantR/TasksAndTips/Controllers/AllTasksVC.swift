//
//  AllTasksVC.swift
//  plantR_ios
//
//  Created by Mathieu Rabissoni on 17/04/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class AllTasksVC: UIViewController {

    @IBOutlet weak var namePlantLabel: UILabel!
    @IBOutlet weak var plantsImageView: CornerImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleDetailLabel: UILabel!
    
    private var toDoTasksDict: [GardenerTaskModelToAllTasks] = []
    private var handleTasks: UInt?
    private var gardenerPlantRef: DatabaseReference!
    
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!
    
    var key: String?
    var gardenerId: String?
    var plant: GardenerPlantModel?
    var plantModel: InfosPlants?
    var plantUID: String?
    
    var gardener: GardenerModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let plant = self.plant, let plantModel = self.plantModel, let key = self.key, let gardenerId = self.gardenerId else { return }
        if plant.plantName.isEmpty {
            self.namePlantLabel.text = plantModel.infoPlant.name
        } else {
            self.namePlantLabel.text = plant.plantName
        }
        if plant.picture {
            let imageRef = self.gardenerRepository.getGardenerPlantStageAndRowStorage(by: gardenerId, by: key)
            self.plantsImageView.sd_setImage(with: imageRef)
        } else {
            self.plantsImageView.sd_setImage(with: plantModel.imagePlant)
        }
        self.gardenerPlantRef =  self.gardenerRepository.getPlantStageAndRowReference(by: gardenerId, by: key)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let gId = gardenerId else { return }

        self.gardenerRepository.getReference(for: gId).observeSingleEvent(of: .value, with: { snap in
            self.gardener = self.gardenerTransformer.toGardenerModel(snap: snap)
            self.handleTasks = self.gardenerPlantRef.observe(.value, with: { (snapPlant) in
                let value = snapPlant.value as! [String: Any]
                guard let key = self.key else { return }
                
                let endOfToday = self.endOfDay(Date())
                self.toDoTasksDict = self.gardenerTransformer.toAllTasksWithOnePlant(value, stageAndRow: key).filter({ $0.task.doneInTime == nil}).filter({ $0.task.date < endOfToday })
                self.tableView.reloadData()
                
                if self.toDoTasksDict.isEmpty {
                    self.titleDetailLabel.text = NSLocalizedString("you_have_no_more_tasks_to_perform", comment: "you_have_no_more_tasks_to_perform")
                    
                } else {
                    self.titleDetailLabel.text = NSLocalizedString("touch_a_task_to_get_its_details", comment: "touch_a_task_to_get_its_details")
                }
                self.titleDetailLabel.isHidden = false
            })
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let handleTasks = self.handleTasks {
            self.gardenerPlantRef.removeObserver(withHandle: handleTasks)
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func endOfDay(_ date: Date) -> Date {
        var endOfDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: date))
        endOfDate = Calendar.current.date(byAdding: .second, value: -1, to: Calendar.current.startOfDay(for: endOfDate!))
        return endOfDate!
    }
}

extension AllTasksVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let plantUID = plantUID, let plant = plant else { return }
        let controller = StoryboardScene.TasksAndTips.newTaskDetailVC.instantiate()
        
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        
        controller.taskModel = self.toDoTasksDict[indexPath.row]
        controller.gardener = gardener
        controller.plantUID = plantUID
        controller.notification = false
        self.present(controller, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.toDoTasksDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allTasksCell", for: indexPath) as! AllTaskTVC
        cell.titleTaskLabel.text = self.toDoTasksDict[indexPath.row].task.title
        cell.descriptionLabel.text = self.toDoTasksDict[indexPath.row].task.description
        return cell
    }
}
