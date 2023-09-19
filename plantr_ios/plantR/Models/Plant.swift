//
//  Plant.swift
//  plantR_ios
//
//  Created by Mathieu Rabissoni on 08/04/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import Foundation
import Firebase

private enum PlantConsts {
    static let RootNode = "plants"
    static let FilterTask = "filterTask"
    static let Characteristic = "characteristic"
    static let Association = "association"
    static let HarvestPeriod = "harvestPeriod"
    static let SowingPeriod = "sowingPeriod"
    static let PlantingPeriod = "plantingPeriod"
    static let Tasks = "tasks"
    static let Description = "description"
    static let Name = "name"
    static let Filter = "filtre"
    static let PlantImage = "plant.jpg"
}

private enum CategoryConst {
    static let RootNode = "categories"
    static let name = "name"
}

enum FilterTaskConst {
    static let Planter = "planter"
    static let Semer = "semer"
}

protocol PlantTransformer {
    func toPlantModelWithDict(dict: [String: Any]) -> PlantModel
    func toPlantCharacteristicModel(_ metaDict: [String: Any]) -> PlantCharacteristicModel
    func toPlantHarvestPeriodModel(_ metaDict: [String: Any]) -> PlantHarvestPeriodModel
    func toPlantSowingPeriodModel(_ metaDict: [String: Any]) -> PlantSowingPeriodModel
    func toCategoriesModel(_ metaDict: [String: Any]) -> [CategoryModel]
    func toFilterTaskModel(_ metaDict: [String: Any]) -> FilterTask
}

class PlantTransformerImpl: PlantTransformer {
    
    private enum Consts {
        static let Water = "water"
        static let Exhibition = "exhibition"
        static let Height = "height"
        static let Rusticite = "rusticite"
        static let EndMonth = "endMonth"
        static let StartMonth = "startMonth"
        static let GrowingTime = "growingTime"
        static let DayFromPlantation = "dayFromPlantation"
        static let Description = "description"
        static let Title = "title"
        static let TaskId = "taskId"
    }
    
    func toPlantModelWithDict(dict: [String: Any]) -> PlantModel {
        let association = dict[PlantConsts.Association] as? [String: Any] ?? [:]
        let characteristicDict = dict[PlantConsts.Characteristic] as? [String: Any] ?? [:]
        let description = dict[PlantConsts.Description] as? String ?? ""
        let name = dict[PlantConsts.Name] as? String ?? ""
        let filter = dict[PlantConsts.Filter] as? [String: Any] ?? [:]
        let HarvestPeriodDict = dict[PlantConsts.HarvestPeriod] as? [String: Any] ?? [:]
        let SowingPeriodDict = dict[PlantConsts.SowingPeriod] as? [String: Any] ?? [:]
        let plantingPeriodDict = dict[PlantConsts.PlantingPeriod] as? [String: Any] ?? [:]
        let tasksDict = dict[PlantConsts.Tasks] as? [Any] ?? []
        var arrayPlantTaskModel: [PlantTasksModel] = []
        for task in tasksDict {
            if let notNullTask = task as? [String: Any] {
                let plantTaskModel = self.toPlantTaskModel(notNullTask)
                arrayPlantTaskModel.append(plantTaskModel)
            } else {
                let plantTaskModelNull = self.toPlantTaskModel([:])
                arrayPlantTaskModel.append(plantTaskModelNull)
                print(arrayPlantTaskModel)
            }
        }
/*        let tasksDistFormated = tasksDict.count > 0 ? tasksDict.map { self.toPlantTaskModel($0 as! [String: Any]) } : [PlantTasksModel(dayFromPlantation: 0, description: "", title: "")]*/
        
        return PlantModel(association: association, characteristic: toPlantCharacteristicModel(characteristicDict), description: description, name: name, filter: toPlantFilteredModel(filter), harvestPeriod: toPlantHarvestPeriodModel(HarvestPeriodDict), sowingPeriod: toPlantSowingPeriodModel(SowingPeriodDict), plantingPeriod: toPlantPlantingPeriodModel(plantingPeriodDict), task: arrayPlantTaskModel)
    }
    
    func toPlantFilteredModel(_ metaDict: [String: Any]) -> [String] {
        var filterList: [String] = []
        metaDict.forEach({ filterList.append($0.key) })
        return filterList
    }
    
    func toPlantCharacteristicModel(_ metaDict: [String: Any]) -> PlantCharacteristicModel {
        let water = metaDict[Consts.Water] as? Int ?? 0
        let exhibition = metaDict[Consts.Exhibition] as? Int ?? 0
        let height = metaDict[Consts.Height] as? String ?? ""
        let rusticite = metaDict[Consts.Rusticite] as? Int ?? 0
        return PlantCharacteristicModel(water: water, exhibition: exhibition, height: height, rusticite: rusticite)
    }
    
    func toPlantHarvestPeriodModel(_ metaDict: [String: Any]) -> PlantHarvestPeriodModel {
        let startMonth = metaDict[Consts.StartMonth] as? Int ?? 1
        let endMonth = metaDict[Consts.EndMonth] as? Int ?? 1
        return PlantHarvestPeriodModel(endMonth: endMonth, startMonth: startMonth)
    }
    
    func toPlantPlantingPeriodModel(_ metaDict: [String: Any]) -> PlantingPeriodModel {
        let startMonth = metaDict[Consts.StartMonth] as? Int ?? 1
        let endMonth = metaDict[Consts.EndMonth] as? Int ?? 1
        return PlantingPeriodModel(endMonth: endMonth, startMonth: startMonth)
    }
    
    func toPlantSowingPeriodModel(_ metaDict: [String: Any]) -> PlantSowingPeriodModel {
        let startMonth = metaDict[Consts.StartMonth] as? Int ?? 1
        let endMonth = metaDict[Consts.EndMonth] as? Int ?? 1
        let growingTime = metaDict[Consts.GrowingTime] as? Int ?? 1
        return PlantSowingPeriodModel(endMonth: endMonth, startMonth: startMonth, growingTime: growingTime)
    }
    
    private func toPlantTaskModel(_ metaDict: [String?: Any]) -> PlantTasksModel {
        let dayFromPlantation = metaDict[Consts.DayFromPlantation] as? Int ?? 0
        let description = metaDict[Consts.Description] as? String ?? ""
        let title = metaDict[Consts.Title] as? String ?? ""
        let taskId = metaDict[Consts.TaskId] as? String ?? ""
        return PlantTasksModel(dayFromPlantation: dayFromPlantation, description: description, title: title, taskId: taskId)
    }
    
    func toCategoriesModel(_ metaDict: [String: Any]) -> [CategoryModel] {
        var arrayCat:[CategoryModel] = []
        metaDict.forEach({ arrayCat.append(CategoryModel(name: ($0.value as? [String: String])?["name"] ?? "", id: $0.key)) })
        return arrayCat
    }
    
    func toFilterTaskModel(_ metaDict: [String : Any]) -> FilterTask {
        var filterTask = FilterTask()
        (metaDict[FilterTaskConst.Semer] as? [String:Bool] ?? [:]).forEach { filterTask.semer.append($0.key.lowercased()) }
        (metaDict[FilterTaskConst.Planter] as? [String:Bool] ?? [:]).forEach { filterTask.planter.append($0.key.lowercased()) }
        return filterTask
    }
    
}

protocol PlantRepository {
    func getRootReference() -> DatabaseReference
    func getReference(for key: String) -> DatabaseReference
    func getCharacteristicReference(for key: String) -> DatabaseReference
    func getHarvestPeriodReference(for key: String) -> DatabaseReference
    func getSowingPeriodReference(for key: String) -> DatabaseReference
    func getTasksReference(for key: String) -> DatabaseReference
    func getPlantNameReference(for key: String) -> DatabaseReference
    func getPicturePlanteStorageReference(for key: String) -> StorageReference
    func getTaskPictureStorageReference(for key: String, name: String) -> StorageReference
    func getFilterTask() -> DatabaseReference
    
    func getStorageImageBy(id: String) -> StorageReference
    func getCategories() -> DatabaseReference
}

class PlantRepositoryImpl: PlantRepository {
    
    func getFilterTask() -> DatabaseReference {
        return Database.database().reference(withPath: PlantConsts.FilterTask)
    }
    
    func getRootReference() -> DatabaseReference {
        return Database.database().reference(withPath: PlantConsts.RootNode)
    }
    
    func getReference(for key: String) -> DatabaseReference {
        return getRootReference().child(key)
    }
    
    func getCharacteristicReference(for key: String) -> DatabaseReference {
        return getReference(for: key).child(PlantConsts.Characteristic)
    }
    
    func getHarvestPeriodReference(for key: String) -> DatabaseReference {
        return getReference(for: key).child(PlantConsts.HarvestPeriod)
    }
    
    func getPlantingPeriodReference(for key: String) -> DatabaseReference {
        return getReference(for: key).child(PlantConsts.PlantingPeriod)
    }
    
    func getSowingPeriodReference(for key: String) -> DatabaseReference {
        return getReference(for: key).child(PlantConsts.SowingPeriod)
    }
    
    func getTasksReference(for key: String) -> DatabaseReference {
        return getReference(for: key).child(PlantConsts.Tasks)
    }
    
    func getPlantNameReference(for key: String) -> DatabaseReference {
        return getReference(for: key).child(PlantConsts.Name)
    }
    
    func getPicturePlanteStorageReference(for key: String) -> StorageReference {
        return Storage.storage().reference(withPath: PlantConsts.RootNode).child(key).child(PlantConsts.PlantImage)
    }
        
    func getTaskPictureStorageReference(for key: String, name: String) -> StorageReference {
        return Storage.storage().reference(withPath: PlantConsts.RootNode).child(key).child(PlantConsts.Tasks).child("\(name.lowercased()).jpg")
    }
    
    func getStorageImageBy(id: String) -> StorageReference {
        return Storage.storage().reference(withPath: CategoryConst.RootNode).child("\(id).jpg")
    }
    
    func getCategories() -> DatabaseReference {
        return Database.database().reference(withPath: CategoryConst.RootNode)
    }
}

struct PlantCharacteristicModel {
    let water: Int
    let exhibition: Int
    let height: String
    let rusticite: Int
}

struct PlantModel {
    let association: [String: Any]
    let characteristic: PlantCharacteristicModel
    let description: String
    let name: String
    let filter: [String]
    let harvestPeriod: PlantHarvestPeriodModel
    let sowingPeriod: PlantSowingPeriodModel
    let plantingPeriod: PlantingPeriodModel
    let task: [PlantTasksModel]
}

struct PlantHarvestPeriodModel {
    let endMonth: Int
    let startMonth: Int
}

struct PlantingPeriodModel {
    let endMonth: Int
    let startMonth: Int
}

struct PlantSowingPeriodModel {
    let endMonth: Int
    let startMonth: Int
    let growingTime: Int
}

struct PlantTasksModel {
    let dayFromPlantation: Int
    let description: String
    let title: String
    let taskId: String
}

struct InfosPlants {
    let infoPlant: PlantModel
    let imagePlant: StorageReference
}

struct CategoryModel {
    let name: String
    let id: String
}

struct FilterTask {
    var semer: [String] = []
    var planter: [String] = []
}
