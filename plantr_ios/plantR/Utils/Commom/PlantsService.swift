//
//  PlantsService.swift
//  plantR_ios
//
//  Created by Boris Roussel on 11/04/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import Firebase

class PlantsService {
    
    private let plantRepository: PlantRepository
    private let plantTransformer: PlantTransformer
    
    private(set) var plants: [String: InfosPlants] = [:]
    private(set) var categories: [CategoryModel] = []
    private(set) var filterTask: FilterTask = FilterTask()

    init(plantRepository: PlantRepository, plantTransformer: PlantTransformer) {
        self.plantRepository = plantRepository
        self.plantTransformer = plantTransformer
    }

    func refreshService() {
        self.plantRepository.getRootReference().observeSingleEvent(of: .value, with: { (_ snapPlants) in
            let allPlants = snapPlants.value as! [String: Any]
            self.plants =  Dictionary(uniqueKeysWithValues:
                allPlants.map { key, value in (key, self.toInfosPlantsModel(value as! [String: Any], plantID: key)) })
        })
        self.plantRepository.getCategories().observeSingleEvent(of: .value, with: { (_ snapCat) in
            let allCategories = snapCat.value as! [String: Any]
            print("All Catergories => \(allCategories.count)")
            print(allCategories)
            self.categories =  self.plantTransformer.toCategoriesModel(allCategories)
            print(self.categories)
        })
        self.plantRepository.getFilterTask().observeSingleEvent(of: .value, with: { (_ snapFilter) in
            let allFilter = snapFilter.value as! [String: Any]
            self.filterTask = self.plantTransformer.toFilterTaskModel(allFilter)
            print("All Filter => \(self.filterTask.planter.count) \(self.filterTask.semer.count)")
            print(self.filterTask)
        })
    }

    private func toInfosPlantsModel(_ dict: [String: Any], plantID: String) -> InfosPlants {
        let infoPlant = self.plantTransformer.toPlantModelWithDict(dict: dict)
        let imagePlant = self.plantRepository.getPicturePlanteStorageReference(for: plantID)
        return InfosPlants(infoPlant: infoPlant, imagePlant: imagePlant)
    }
}
