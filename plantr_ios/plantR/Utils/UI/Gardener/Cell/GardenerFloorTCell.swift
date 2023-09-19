//
//  GardenerFloorTCell.swift
//  plantR_ios
//
//  Created by Rabissoni on 22/02/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit
import FirebaseUI

protocol GardenerFloorTCellDelegate: class {
    func didPopModalAddPlant(key: String, gardenerId: String)
    func didPopModalInfoPlant(key: String, gardenerId: String, plant: GardenerPlantModel)
}

class GardenerFloorTCell: UITableViewCell {

    @IBOutlet var stageImage: UIImageView!
    @IBOutlet var stageName: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    var plants: [String: GardenerPlantModel] = [:]
    var plantsModel: [String: InfosPlants] = [:]
    var stageRow: Int = 0
    var stage: Int = 0
    var gardenerId: String?
    var visited = false
    
    weak var delegate: GardenerFloorTCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.register(UINib(nibName: "GardenerAddCCell", bundle: nil), forCellWithReuseIdentifier: "GardenerAddCCell")
        self.collectionView.register(UINib(nibName: "GardenerPlantCCell", bundle: nil), forCellWithReuseIdentifier: "GardenerPlantCCell")
        self.collectionView.register(UINib(nibName: "GardenerEmptyCCell", bundle: nil), forCellWithReuseIdentifier: "GardenerEmptyCCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension GardenerFloorTCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return stageRow
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let key = getKeyForItemWithStageAndIndexPath(stage: stage, indexPath: indexPath)
        
        guard let plant = plants[key] else {
            if (visited) {
                 let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GardenerEmptyCCell", for: indexPath) as! GardenerEmptyCCell
                 return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GardenerAddCCell", for: indexPath) as! GardenerAddCCell
                return cell
            }
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GardenerPlantCCell", for: indexPath) as! GardenerPlantCCell

        if plant.plantName == "", let plantModel = plantsModel[plant.plantID] {
            cell.nameLabel.text = plantModel.infoPlant.name
        } else {
            cell.nameLabel.text = plant.plantName
        }
        
        if let image = plantsModel[plant.plantID] {
            cell.imageView.sd_setImage(with: image.imagePlant)
        }
        
        let progressValue = setProgressBar(start: plant.dateSowing.timeIntervalSince1970, end: plant.dateHarvested.timeIntervalSince1970, current: Date().timeIntervalSince1970)
        cell.progressBar.setProgress(progressValue, animated: true)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let key = getKeyForItemWithStageAndIndexPath(stage: stage, indexPath: indexPath)
        guard let gardenerId = gardenerId else { return }
        guard let plant = plants[key] else {
            delegate?.self.didPopModalAddPlant(key: key, gardenerId: gardenerId)
            return
        }
        delegate?.self.didPopModalInfoPlant(key: key, gardenerId: gardenerId, plant: plant)
    }
    
    func setProgressBar(start: Double, end: Double, current: Double) -> Float {
        return Float((current - start) / (end - start))
    }
    
    func getKeyForItemWithStageAndIndexPath(stage: Int, indexPath: IndexPath) -> String {
        return "\(stage)-\(indexPath.row)"
    }
}
