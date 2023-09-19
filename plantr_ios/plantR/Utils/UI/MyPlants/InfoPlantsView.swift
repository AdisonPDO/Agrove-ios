//
//  InfoPlantsView.swift
//  plantR_ios
//
//  Created by Mathieu Rabissoni on 15/04/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit
import FirebaseUI

class InfoPlantsView: UIView {

    @IBOutlet weak var namePlantsLabel: UILabel!
    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var plantModel: InfosPlants?
    private var headerView: InformationPlantsHeaderView!
    var boolLoop: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func selectMonth(start: Int, end: Int, array: [UILabel]) {
        var incr: Int
        incr = start
        boolLoop = true
        while boolLoop {
            array[incr].backgroundColor = Styles.PlantRMainGreen
            array[incr].textColor = .white
            if incr == start {
                array[incr].layer.cornerRadius = 7.5
                array[incr].clipsToBounds = true
                array[incr].layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            }
            if incr == end {
                boolLoop = false
                array[incr].layer.cornerRadius = 7.5
                array[incr].clipsToBounds = true
                array[incr].layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            } else if incr == 11 {
                incr = 0
            } else {
                incr += 1
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("InformationPlants", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        let nibCell = UINib(nibName: "TasksTVC", bundle: nil)
        let nibHeader = UINib(nibName: "InformationPlantsHeaderView", bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: "TasksTVC")
        tableView.register(nibHeader, forHeaderFooterViewReuseIdentifier: "PlantHeader")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setAllInformation(plantModel: InfosPlants) {
        self.namePlantsLabel.text = plantModel.infoPlant.name
        self.plantImage.sd_setImage(with: plantModel.imagePlant)
        self.tableView.reloadData()
    }
    
    func setHarvestSowingInfo(plantModel: InfosPlants) {
        self.plantModel = plantModel
        self.tableView.reloadData()
    }
    
    func getImageTaskByTitle(title: String) -> UIImage {
        switch title {
        case "Recolter":
            return UIImage(named: "iconeRecolter")!
        case "Repiquer":
            return UIImage(named: "iconeSemer")!
        default:
            return UIImage(named: "iconeEntretenir")!
        }
    }
}

extension InfoPlantsView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let plant = plantModel else { return  0 }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        self.headerView = InformationPlantsHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 800))
        guard let plantModel = self.plantModel else { return headerView }
        self.namePlantsLabel.text = plantModel.infoPlant.name
        self.plantImage.sd_setImage(with: plantModel.imagePlant)
        self.selectMonth(start: plantModel.infoPlant.sowingPeriod.startMonth - 1, end: plantModel.infoPlant.sowingPeriod.endMonth - 1, array: self.headerView.seedlingArrayLabel)
        self.selectMonth(start: plantModel.infoPlant.harvestPeriod.startMonth - 1, end: plantModel.infoPlant.harvestPeriod.endMonth - 1, array: self.headerView.harvestArrayLabel)
        headerView.setAllHeaderInformation(plantModel: plantModel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksTVC", for: indexPath) as! TasksTVC
        guard let plant = plantModel else { return cell }
        cell.descriptionLabel.text = plant.infoPlant.task[indexPath.row].description
        cell.titleLabel.text = plant.infoPlant.task[indexPath.row].title
        cell.tasksImageView.image = self.getImageTaskByTitle(title: plant.infoPlant.task[indexPath.row].title)
        return cell
    }
}
