//
//  TasksVC.swift
//  plantR_ios
//
//  Created by Rabissoni on 06/02/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit
import JTAppleCalendar
import Foundation
import Firebase
import FirebaseUI

enum TasksState {
    case done
    case todo
}

class TasksVC: UIViewController {
    
    var userRepository: UserRepository!
    var userTransformer: UserTransformer!
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!
    var plantsService: PlantsService!
    
    @IBOutlet var leftCalendarButton: UIButton!
    @IBOutlet var rightCalendarButton: UIButton!
    
    @IBOutlet var calendarView: JTAppleCalendarView!
    @IBOutlet var monthsLabel: UILabel!
    @IBOutlet var yearLabel: UILabel!
    @IBOutlet var calendarViewContainer: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet weak var noTaskToShow: UILabel!
    @IBOutlet var scTasks: UISegmentedControl!
    
    private var selectedDate: Date? = nil
    
    private var currentUser: User!
    private var currentGardener: String?
    private var currentGardenerModel: GardenerModel?
    
    private var allPlants: [String: GardenerTaskModelToAllTasks] = [:]
    private var tasksToDo: [GardenerTaskModelToAllTasks] = []
    private var tasksDo: [GardenerTaskModelToAllTasks] = []
    
    private var listDateTasks: [Date : [GardenerTaskModelToAllTasks]] = [:]
    
    private var currentGardenerRef: DatabaseReference!
    private var currentGardenerReference: DatabaseReference!
    
    private var handleCurrentGardener: UInt?
    private var handleAllPlants: UInt?
    
    private var currentDate = Date()
    private var oldestTask = Date()
    private let todayDate = Date()
    private var endOfToday: Date!
    private let formatter = DateFormatter()
    
    private var taskState: TasksState = .todo
    
    private var allTasks: [GardenerTaskModelToAllTasks] = []
    @IBOutlet var customSegmentedControl: CustomSegmentedControl!{
        didSet{
            customSegmentedControl.setButtonTitles(buttonTitles: [NSLocalizedString("to_dom", comment: "to do"),NSLocalizedString("jobs_donem", comment: "jobs done")])
/*
                customSegmentedControl.selectorViewColor = .white
            customSegmentedControl.selectorTextColor = .white
            customSegmentedControl.backgroundColor = .clear*/
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.locale = Locale.init(identifier: NSLocalizedString("local", comment: "local"))
        customSegmentedControl.delegate = self
        customSegmentedControl.selectorTextColor = .white
        customSegmentedControl.selectorViewColor = .white
        customSegmentedControl.backgroundColor = .clear
        calendarViewContainer.heightAnchor.constraint(equalToConstant: 400).isActive = true
        if UIDevice.current.userInterfaceIdiom == .pad {
            stackView.insertArrangedSubview(calendarViewContainer, at: 0)
        } else {
            tableView.tableHeaderView = calendarViewContainer
        }
        setupCalendar()
        self.currentUser = Auth.auth().currentUser
        self.currentGardenerRef = self.userRepository.getCurrentGardenerReference(for: currentUser.uid)
        self.endOfToday = self.endOfDay(todayDate)
    }
    
    fileprivate func setFilteredTask(_ list: [GardenerTaskModelToAllTasks]) -> [GardenerTaskModelToAllTasks] {
        var arrPriority: [GardenerTaskModelToAllTasks] = []
        var arrRecolt: [GardenerTaskModelToAllTasks] = []
        var rest: [GardenerTaskModelToAllTasks] = []
        var finalList: [GardenerTaskModelToAllTasks] = []
        
        //TODO: OPTI LE CODE -> FUNCTION EXTERNE
        list.forEach {
            print("nonono -> \($0.status) ===> \($0.task.title)")
            if($0.status == "planter"){
                if($0.task.title.lowercased() != "preparer" && $0.task.title.lowercased() != "semer" && $0.task.title.lowercased() != "repiquer" && $0.task.title.lowercased() != "éclaircir" && $0.task.title.lowercased() != "prepare" && $0.task.title.lowercased() != "sow" && $0.task.title.lowercased() != "transplant" && $0.task.title.lowercased() != "lighten"){
                    if ($0.task.priority == 1) {
                        arrPriority.append($0)
                    } else if $0.task.title == NSLocalizedString("collect", comment: "collect"){
                        arrRecolt.append($0)
                    } else {
                        rest.append($0)
                    }
                }
            }else{
                if($0.task.title.lowercased() != "planter" && $0.task.title.lowercased() != "enrichir" && $0.task.title.lowercased() != "plant" && $0.task.title.lowercased() != "enrich"){
                    if ($0.task.priority == 1) {
                        arrPriority.append($0)
                    } else if $0.task.title == NSLocalizedString("collect", comment: "collect"){
                        arrRecolt.append($0)
                    } else {
                        rest.append($0)
                    }
                }
            }
        }
        
        finalList += arrPriority
        finalList += arrRecolt
        finalList += rest
        
        return finalList
    }
    
    fileprivate func setListWithDate() {
        
        var selectedDate = self.selectedDate == nil ? self.endOfToday! : self.selectedDate ?? self.endOfToday!
        print("SELECTED DATE => \(selectedDate)")
        var allTaskFiltered = self.allTasks.filter({ $0.task.date < selectedDate})
        
        let grouping = Dictionary(grouping: allTaskFiltered, by: { $0.task.doneInTime == nil })
        
        self.tasksDo = self.setFilteredTask(grouping[false] ?? [])
        self.tasksToDo = self.setFilteredTask(grouping[true] ?? [])
        self.listDateTasks = Dictionary(grouping: allTaskFiltered, by: { Calendar.current.startOfDay(for: $0.task.date) })
        if !self.listDateTasks.isEmpty {
            let oldTask = self.listDateTasks.sorted(by: { $0.key.compare($1.key) == .orderedAscending })
            self.oldestTask = oldTask.first!.key
        }
        
        print("********** RELOAD ***********")
        self.noTaskToShow.isHidden = true
        
        if taskState == .todo && self.tasksToDo.isEmpty {
            self.noTaskToShow.isHidden = false
            self.noTaskToShow.text = self.currentGardenerModel?.taskPlants.isEmpty == true ? NSLocalizedString("you_have_no_task_to_archieve_because_you_have_not_yet_added_any_plants", comment: "you_have_no_task_to_archieve_because_you_have_not_yet_added_any_plants") : NSLocalizedString("you_have_no_tasks_to_achieve_so_far", comment: "you_have_no_tasks_to_achieve_so_far")
        }
        if taskState == .done && self.tasksDo.isEmpty {
            self.noTaskToShow.isHidden = false
            self.noTaskToShow.text = NSLocalizedString("you_have_no_completed_tasks", comment: "you_have_no_completed_tasks")
        }
       
        self.tableView.reloadData()
        self.calendarView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.handleCurrentGardener = self.currentGardenerRef.observe(.value, with: {(snapCurrentGardener) in
            let currentGardener = snapCurrentGardener.value as! String
            self.currentGardener = currentGardener
            self.currentGardenerReference = self.gardenerRepository.getReference(for: currentGardener)
            self.handleAllPlants = self.currentGardenerReference.observe(.value, with: { (snapPlants) in
                
                self.currentGardenerModel = self.gardenerTransformer.toGardenerModel(snap: snapPlants)
                self.allTasks = (self.currentGardenerModel?.taskPlants ?? []).filter ({
                    let status = $0.status
                    switch (status) {
                    case FilterTaskConst.Planter:
//                        print("Planter - \($0.task.title.lowercased()) - \(self.plantsService.filterTask.planter) - => \(self.plantsService.filterTask.planter.contains($0.task.title.lowercased()))")
                        return !self.plantsService.filterTask.planter.contains($0.task.title.lowercased())
                    case FilterTaskConst.Semer:
//                        print("Semer - \($0.task.title.lowercased()) - \(self.plantsService.filterTask.semer) -  => \(self.plantsService.filterTask.semer.contains($0.task.title.lowercased()))")
                        return !self.plantsService.filterTask.semer.contains($0.task.title.lowercased())
                    default:
                        return true
                    }
                })

                self.allPlants = [:]
                self.allTasks.forEach { task in
                    self.allPlants.updateValue(task, forKey: task.stageAndRow)
                }
                /*self.allPlants = plants.mapValues { self.gardenerTransformer.toGardenerPlantModel($0 as! [String: Any]) }*/

                self.setListWithDate()
                self.calendarView.scrollToDate(self.todayDate)
//                self.checkToHiddenArrow()
            })
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let handleCurrentGardener = self.handleCurrentGardener {
            self.currentGardenerRef.removeObserver(withHandle: handleCurrentGardener)
        }
        if let handleAllPlants = self.handleAllPlants {
            self.currentGardenerReference.removeObserver(withHandle: handleAllPlants)
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func checkToHiddenArrow() {
        
        let currentDateComponent = Calendar.current.dateComponents([.year, .month], from: self.currentDate)
        let todayDateComponent = Calendar.current.dateComponents([.year, .month], from: self.todayDate)
        let oldestDateComponent = Calendar.current.dateComponents([.year, .month], from: self.oldestTask)
        
        if (todayDateComponent.year! <= currentDateComponent.year! && todayDateComponent.month! <= currentDateComponent.month!) {
            self.rightCalendarButton.isEnabled = false
        } else {
            self.rightCalendarButton.isEnabled = true
        }
        
        if (currentDateComponent.year! <= oldestDateComponent.year! && currentDateComponent.month! <= oldestDateComponent.month!) {
            self.leftCalendarButton.isEnabled = false
        } else {
            self.leftCalendarButton.isEnabled = true
        }
    }
    
    @IBAction func checkToMove(_ sender: UIButton) {
        if sender == rightCalendarButton {
            self.currentDate = Calendar.current.date(byAdding: .month, value: 1, to: self.currentDate)!
            self.calendarView.scrollToSegment(.next)
        } else {
            self.currentDate = Calendar.current.date(byAdding: .month, value: -1, to: self.currentDate)!
            self.calendarView.scrollToSegment(.previous)
        }
        self.calendarView.scrollToDate(self.currentDate)
//        checkToHiddenArrow()
    }
    
    fileprivate func setupCalendar() {
        self.calendarView.allowsMultipleSelection = false
        self.calendarView.isRangeSelectionUsed = false
        self.calendarView.minimumLineSpacing = 0
        self.calendarView.minimumInteritemSpacing = 0
        self.calendarView.visibleDates { (visibleDates) in
            self.setupViewCalendar(from: visibleDates)
        }
    }
    
    func handleCellSelected(cell: CalendarCell, cellState: CellState) {
        if cellState.isSelected {
            cell.selectedDate.isHidden = false
            cell.selectedDate.layer.borderWidth = 1.5
            cell.selectedDate.layer.borderColor = UIColor.white.cgColor
        } else {
            cell.selectedDate.isHidden = true
        }
    }
    
    fileprivate func configureCell(cell: CalendarCell, cellState: CellState) {
        
        cell.isHidden = cellState.dateBelongsTo != .thisMonth
        let date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        handleCellSelected(cell: cell, cellState: cellState)
        cell.dateLabel.alpha = cellState.date >= date ? 1 : 0.7
    }
    
    func endOfDay(_ date: Date) -> Date {
        var endOfDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: date))
        endOfDate = Calendar.current.date(byAdding: .second, value: -1, to: Calendar.current.startOfDay(for: endOfDate!))
        return endOfDate!
    }
}

extension TasksVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard  let plant = taskState == .todo ? self.allPlants[self.tasksToDo[indexPath.row].stageAndRow] : self.allPlants[self.tasksDo[indexPath.row].stageAndRow], let gardener = self.currentGardenerModel else { return }
        let controller = StoryboardScene.TasksAndTips.newTaskDetailVC.instantiate()
        
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        
        controller.taskModel = taskState == .todo ? self.tasksToDo[indexPath.row] : self.tasksDo[indexPath.row]
        controller.gardener = gardener
        controller.plantUID = plant.plantId
        controller.notification = false
        
        self.present(controller, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func  tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch taskState {
        case .todo:
            return self.tasksToDo.count
        case .done:
            return self.tasksDo.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskDoItCell", for: indexPath) as! TaskDoItCVCell
        
        let infoTask = self.taskState == .todo ? self.tasksToDo[indexPath.row] : self.tasksDo[indexPath.row]
        
        if let plant = self.taskState == .todo ? self.allPlants[infoTask.stageAndRow] : self.allPlants[infoTask.stageAndRow], let plantModel = plantsService.plants[plant.plantId] {
            if plant.plantName.isEmpty {
                cell.namePlantLabel.text = plantModel.infoPlant.name
            } else {
                cell.namePlantLabel.text = plant.plantName
            }
            
            
            if plant.picture == false {
                cell.plantImageView.sd_setImage(with: plantModel.imagePlant)
            } else {
                let image = self.gardenerRepository.getGardenerPlantStageAndRowStorage(by: currentGardener!, by: infoTask.stageAndRow)
                cell.plantImageView.sd_setImage(with: image)
            }
        }
        switch infoTask.task.priority {
        case 1:
            cell.ivPriority.image = UIImage(named: "priority")
            if(taskState == .todo){
                cell.ivPriority.isHidden = false
            }else{
                cell.ivPriority.isHidden = true
            }
        default:
            cell.ivPriority.isHidden = true
        }
        if (infoTask.task.title == NSLocalizedString("collect", comment: "collect")) {
            cell.ivPriority.image = UIImage(named: "recolte")
            cell.ivPriority.isHidden = false
        }

        cell.nameTaskLabel.text = UtilsCategories().getTaskNameTrad(str: infoTask.task.title).uppercased()
        return cell
    
    }
}
extension TasksVC: CustomSegmentedControlDelegate {
    func change(to index: Int) {
        switch index {
        case 0:
            taskState = .todo
            setListWithDate()
        case 1:
            taskState = .done
            setListWithDate()
        default:
            taskState = .todo
        }
    }
}

extension TasksVC: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
    }
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        let parameters = ConfigurationParameters(startDate: self.oldestTask, endDate: Calendar.current.date(byAdding: .year, value: 1, to: self.oldestTask)!, numberOfRows: 6, calendar: Calendar.current, generateInDates: InDateCellGeneration.forAllMonths, generateOutDates: OutDateCellGeneration.tillEndOfGrid, firstDayOfWeek: .monday, hasStrictBoundaries: false)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        
        cell.dateLabel.text = cellState.text
        
        let startOfDay =  Calendar.current.startOfDay(for: date)
        
/*        if let tasks = listDateTasks[startOfDay] {
            if tasks.first(where: { $0.task.doneInTime == false }) != nil {
                cell.taskDayView.backgroundColor = Styles.PlantRRedTasksCalendar
                cell.taskDayWhiteView.isHidden = false
                cell.taskDayView.isHidden = false
            } else if tasks.first(where: { $0.task.doneInTime == true }) != nil {
                cell.taskDayView.backgroundColor = Styles.PlantRGreenTasksCalendar
                cell.taskDayWhiteView.isHidden = false
                cell.taskDayView.isHidden = false
            } else {
                cell.taskDayWhiteView.isHidden = true
                cell.taskDayView.isHidden = true
            }
        } else {
            cell.taskDayWhiteView.isHidden = true
            cell.taskDayView.isHidden = true
        }*/
        
        if Calendar.current.isDate(todayDate, inSameDayAs: date) {
            cell.todayDayView.isHidden = false
            cell.dateLabel.textColor = Styles.PlantRDarkGrey
        } else {
            cell.todayDayView.isHidden = true
            cell.dateLabel.textColor = Styles.PlantRDefaultBackground
        }
        cell.taskDayView.isHidden = true
        cell.taskDayWhiteView.isHidden = true
        self.configureCell(cell: cell, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        
        print("\(cellState.date) ---------- \(date)")
        let date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        return true//cellState.date >= date
    }
        
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? CalendarCell else { return }
        print("didSelectDate")
        if let selectedDate = selectedDate {
            if (Calendar.current.isDate(date, inSameDayAs: selectedDate)) {
                self.selectedDate = nil
                self.calendarView.deselectAllDates()
                self.setListWithDate()
            } else {
                self.selectedDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date)
                self.setListWithDate()
                self.configureCell(cell: cell, cellState: cellState)
            }
        } else {
            self.selectedDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date)
            self.setListWithDate()
            self.configureCell(cell: cell, cellState: cellState)
        }
    }
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? CalendarCell else { return }
        self.configureCell(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        guard let dateCurrent = visibleDates.monthDates.first?.date else {
            return
        }
        self.currentDate = dateCurrent
        let date = visibleDates.monthDates.first!.date
        formatter.dateFormat =  "MMMM"
        self.monthsLabel.text = formatter.string(from: date).capitalized
        formatter.dateFormat =  "yyyy"
        self.yearLabel.text = formatter.string(from: date)
    }
    
    func setupViewCalendar(from visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        formatter.dateFormat =  "MMMM"
        self.monthsLabel.text = formatter.string(from: date).capitalized
        formatter.dateFormat =  "yyyy"
        self.yearLabel.text = formatter.string(from: date)
    }
}
