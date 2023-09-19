//
//  Gardener.swift
//  plantR_ios
//
//  Created by Boris Roussel on 28/02/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import Foundation
import Firebase

enum GardenerType {
    static let Classic = "classic"
    static let Agrove = "agrove"
    static let Pot = "Pot"
    static let Carre = "Carré"
    static let Jardinière = "Jardinière"
    static let KitCapteur = "kit_capteur"
}

enum FormPickerType {
    static let Place = "tfPlace"
    static let Sun = "tfSun"
    static let Orientation = "tfOrient"
}
enum DimensionType {
    static let PotAllDim = 1
    static let Carre0 = 2
    static let Carre1 = 3
    static let Carre2 = 4
    static let Jardiniere0 = 2
    static let Jardiniere1 = 2
    static let Jardiniere2 = 4
}

enum GardenerConsts {
    static let PrefixClassic = "Classic"
    static let RootNode = "gardeners"
    static let StepNode = "etapes"
    static let Owner = "owner"
    static let Owners = "owners"
    static let Metadata = "metadata"
    static let Friends = "friends"
    static let Invitation = "invitation"
    static let Climat = "climat"
    static let Images = "images"
    static let Stats = "stats"
    static let Plants = "plants"
    static let Wishlist = "favoris"
    static let Tips = "tips"
    static let PlantsToAdd = "plantsToAdd"
    static let PlantingToAdd = "plantingToAdd"
    static let PlantingToAddPreviousDate = "plantingToAddPreviousDate"
    static let plantImage = "plant.jpg"
    static let Stage = "stage"
    static let GardenerType = "type"
    static let loraTs = "loraTs"
    static let Dimension = "dimension"
    static let Placement = "emplacement"
    static let SunPosition = "ensoleillement"
    static let OrientationSun = "orientation"
    static let Stages = 4
    static let NumberOfRangs = 2
    static let Rangs = "rangs"
    static let IsPublic = "ispublic"
    static let SubscribeMember = "subscribemember"
    static let NumbersOfPlantsInStage = 4
    static let Classic = "classic"
    static let Agrove = "agrove"
    static let GardenerParent = "gardenerParent"
    static let ZipCode = "zipCode"
    static let CountryCode = "countryCode"
    static let Irrigation = "irrigation"
    static let Reveived = "received"
}

private enum PlantsConsts {
    static let DateHarvested = "dateHarvested"
    static let DateSowing = "dateSowing"
    static let PlantID = "plantID"
    static let PlantName = "plantName"
    static let Picture = "picture"
    static let Tasks = "tasks"
    static let Status = "status"
    static let PreviousDate = "previousDate"
}

private enum WishlistConsts {
    static let PlantingPeriod = "plantingPeriod"
    static let SowingPeriod = "sowingPeriod"
    static let EndMonth = "endMonth"
    static let StartMonth = "startMonth"
    static let GrowingTime = "growingTime"
}

private enum TasksConsts {
    static let Date = "date"
    static let DayFromPlantation = "dayFromPlantation"
    static let Description = "description"
    static let DoneInTime = "doneInTime"
    static let Title = "title"
    static let DoneBy = "doneBy"
    static let Done = "done"
    static let UserId = "userId"
    static let TaskId = "taskId"
    static let Steps = "steps"
    static let Priority = "priority"
    static let DoInTime = "doInTime"
    static let Image = "image"
    static let Tools = "tools"
    static let Url = "url"
}

private enum TipsConst {
    static let Battery = "battery"
    static let Humidity = "humidity"
    static let Luminosity = "luminosity"
    static let SoilMisture = "soilMisture"
    static let SolarPower = "solarPower"
    static let Temperature = "temperature"
    static let WaterLevel = "waterLevel"
    static let Wind = "wind"
}

protocol GardenerTransformer {
    func toGardenerModel(snap: DataSnapshot) -> GardenerModel
    func toGardenerModel(gGModel: GardenerModel) -> [String: Any]
    func toGardenerMetadataModel(_ metaDict: [String: Any]) -> GardenerMetadataModel
    func toDictonary(_ gardenerMetadataModel: GardenerMetadataModel) -> [String: Any]
    func toOwnersModel(_ dictOwners: [String: Any]) -> [String]
    func toTaskDoneDictonary(_ doneBy: TaskDoneBy) -> [String: Any]
    func toGardenerClimatModel(_ climatDict: [String: Any]) -> GardenerClimatModel
    func toGardenerStatsModel(_ statsDict: [String: Any]) -> GardenerStatsModelNew
    func toGardenerPlantModel(_ dictPlant: [String: Any]) -> GardenerPlantModel
    func toGardenerPlantTasks(_ tasksArray: [Any]) -> [Int: GardenerTasksPlantModel]
    func toWishlistModel(_ wishlist: [String: Any]) -> [String: WishlistModel]
    func toDictionaryToAddPlant(_ name: String, plantID: String) -> [String: Any]
    func toDictionaryToAddPlantPreviousDate(_ name: String, plantID: String, previousDate: Int) -> [String: Any]
    func toDictonaryPlantModel(_ gardenerPlantModel: GardenerPlantModel) -> [String: Any]
    func toAllTasksWithManyPlants(_ plants: [String: Any]) -> [GardenerTaskModelToAllTasks]
    func toAllTasksWithOnePlant(_ plant: [String: Any], stageAndRow: String) -> [GardenerTaskModelToAllTasks]
    func toDictonaryWishlistModel(_ wishlistModel: WishlistModel) -> [String: Any]
    func toTipsModel(_ tipsAlert: [String: Any]) -> TipsModel
    func toGardenerClassic(_ classicGardener: ClassicGardener) -> [String: Any]
    func toGardenerParcelle(_ parcelleGardener: ParcelleGardener,_ gardenerRef: String) -> [String: Any]
    func toIrrigation(_ irrigDict: [String: Any]) -> Irrigation
}

class GardenerTransformerImpl: GardenerTransformer {
    
    private enum Consts {
        static let Name = "name"
        static let City = "city"
        static let Address = "address"
        static let Temparature = "temperature"
        static let Wind = "wind"
        static let Humidity = "humidity"
        static let Luminosity = "luminosity"
        static let Battery = "battery"
        static let AirHumidity = "airHumidity"
        static let SoilMistutre = "soilMisture"
        static let SolarPower = "solarPower"
        static let WaterLevel = "waterLevel"
        static let Pressure = "pressure"
        static let Capacities = "capacities"
    }
    
    func toGardenerModel(snap: DataSnapshot) -> GardenerModel {
        //let dict = snap.value as! [String: Any]
        let dict = snap.value as? [String: Any] ?? [:]
        let owners = dict[GardenerConsts.Owners] as? [String: Any] ?? [:]
        let metaDict = dict[GardenerConsts.Metadata] as? [String: Any] ?? [:]
        let friends = dict[GardenerConsts.Friends] as? [String: Any] ?? [:]
        let invitation = dict[GardenerConsts.Invitation] as? String ?? ""
        let owner = dict[GardenerConsts.Owner] as? String ?? ""
        let climatDict = dict[GardenerConsts.Climat] as? [String: Any] ?? [:]
        let wishDict = dict[GardenerConsts.Wishlist] as? [String: Any] ?? [:]
        let statsDict = dict[GardenerConsts.Stats] as? [String: Any] ?? [:]
        let tipsDict = dict[GardenerConsts.Tips] as? [String: Any] ?? [:]
        let tasksPlants = dict[GardenerConsts.Plants] as? [String: Any] ?? [:]
        let stage = dict[GardenerConsts.Stage] as? String ?? "4"
        let type = dict[GardenerConsts.GardenerType] as? String ?? ""
        let dimension = dict[GardenerConsts.Dimension] as? Int ?? -1
        let isPublic = dict[GardenerConsts.IsPublic] as? Bool ?? false
        let subscribeMember = dict[GardenerConsts.SubscribeMember] as? [String: Any] ?? [:]
        let gardenerParent = dict[GardenerConsts.GardenerParent] as? String ?? ""
        let loraTs = dict[GardenerConsts.loraTs] as? String ?? ""
        let rangs = dict[GardenerConsts.Rangs] as? Int ?? 0
        let irrigation = dict[GardenerConsts.Irrigation] as? [String: Any] ?? [:]
        return GardenerModel(id: snap.key, metadata: toGardenerMetadataModel(metaDict), climat: toGardenerClimatModel(climatDict), stats: toGardenerStatsModel(statsDict), friends: friends, owner: owner, owners: owners, wishlist: toWishlistModel(wishDict), invitation: invitation, tips: toTipsModel(tipsDict), taskPlants: toAllTasksWithManyPlants(tasksPlants), stage: stage, ispublic: isPublic, subcribemember: subscribeMember, type: type, dimension: dimension, gardenerParent: gardenerParent, loraTs: loraTs, rangs: rangs, irrigation: toIrrigation(irrigation))
    }
    
    func toIrrigation(_ irrigDict: [String: Any]) -> Irrigation{
        let payload = irrigDict["payload"] as? String ?? ""
        let received = irrigDict["received"] as? [String:Any] ?? [:]
        let requestIrrig = received["request"] as? [String:Any] ?? [:]
        let irrigValue = requestIrrig["value"] as? [String:Any] ?? [:]
        let irrigData = irrigValue["data"] as? String ?? ""
        let status =  received["status"] as? String ?? ""
        let update = received["updated"] as? String ?? ""

        return Irrigation(payload: payload, received: ReceivedIrrg(request: RequestIrrig(value: ValueIrrig(data: irrigData)), status: status, updated: update))
    }

    
    func toGardenerModel(gGModel: GardenerModel) -> [String : Any] {
        return [
            "id": gGModel.id,
            GardenerConsts.Owner: gGModel.owner,
            GardenerConsts.Owners: gGModel.owners,
            GardenerConsts.Friends: gGModel.friends,
            GardenerConsts.Invitation: gGModel.invitation,
            GardenerConsts.Climat: gGModel.climat,
            GardenerConsts.Wishlist: gGModel.wishlist,
            GardenerConsts.Stats: gGModel.stats,
            
        ]
    }
    
    func toGardenerMetadataModel(_ metaDict: [String: Any]) -> GardenerMetadataModel {
        let name = metaDict[Consts.Name] as? String ?? ""
        let city = metaDict[Consts.City] as? String ?? ""
        let address = metaDict[Consts.Address] as? String ?? ""
        let images = metaDict[GardenerConsts.Images] as? [String: Any] ?? [:]
        let placement = metaDict[GardenerConsts.Placement] as? Int ?? 0
        let sunPosition = metaDict[GardenerConsts.SunPosition] as? Int ?? 0
        let orientation = metaDict[GardenerConsts.OrientationSun] as? Int ?? 0
        let zipCode = metaDict[GardenerConsts.ZipCode] as? String ?? ""
        let countryCode = metaDict[GardenerConsts.CountryCode] as? String ?? ""
        return GardenerMetadataModel(name: name, city: city, address: address, zipCode: zipCode, images: images, emplacement: placement, ensoleillement: sunPosition, orientation: orientation, countryCode: countryCode)
    }
    
    func toDictonary(_ gardenerMetadataModel: GardenerMetadataModel) -> [String: Any] {
        return [
            Consts.Name: gardenerMetadataModel.name,
            Consts.City: gardenerMetadataModel.city,
            Consts.Address: gardenerMetadataModel.address,
            GardenerConsts.Images: gardenerMetadataModel.images,
            GardenerConsts.Placement: gardenerMetadataModel.emplacement,
            GardenerConsts.SunPosition: gardenerMetadataModel.ensoleillement,
            GardenerConsts.OrientationSun: gardenerMetadataModel.orientation,
            GardenerConsts.CountryCode: gardenerMetadataModel.countryCode,
            GardenerConsts.ZipCode: gardenerMetadataModel.zipCode
        ]
    }
    
    func toTaskDoneDictonary(_ doneBy: TaskDoneBy) -> [String: Any] {
        return [
            TasksConsts.Date: doneBy.date.timeIntervalSince1970,
            TasksConsts.UserId: doneBy.userId,
        ]
    }
    
    func toGardenerClimatModel(_ climatDict: [String: Any]) -> GardenerClimatModel {
        let temperature = climatDict[Consts.Temparature] as? Int ?? 0
        let wind = climatDict[Consts.Wind] as? Int ?? 0
        let humidity = climatDict[Consts.Humidity] as? Int ?? 0
        let luminosity = climatDict[Consts.Luminosity] as? Int ?? 0
        return GardenerClimatModel(temperature: temperature, wind: wind, humidity: humidity, luminosity: luminosity)
    }
    
    func toCapacities(capa: [String:Int?]) -> Capacities {
        let c1 = capa["c1"] as? Int ?? 0
        let c2 = capa["c2"] as? Int ?? 0
        let c3 = capa["c3"] as? Int ?? 0
        let c4 = capa["c4"] as? Int ?? 0
        let c5 = capa["c5"] as? Int ?? 0
        
        return Capacities(c1: c1, c2: c2, c3: c3, c4: c4, c5: c5)
    }
    
    
    func toGardenerStatsModel(_ statsDict: [String: Any]) -> GardenerStatsModelNew {
        
        let battery = statsDict[Consts.Battery] as? Int ?? 0
        let waterLevel = statsDict[Consts.WaterLevel] as? Int ?? 0
        let temperature = statsDict[Consts.Temparature] as? Float ?? 0.0
        let humidity = statsDict[Consts.Humidity] as? Float ?? 0.0
        let luminosity = statsDict[Consts.Luminosity] as? Int ?? 0
        let pressure = statsDict[Consts.Pressure] as? Float ?? 0.0
        let capacities = statsDict[Consts.Capacities] as? [String:Int] ?? [:]
        return GardenerStatsModelNew(battery: battery, waterLevel: waterLevel, temperature: Int(temperature), humidity: Int(humidity), capacities: toCapacities(capa: capacities), luminosity: Int(luminosity), pressure: Int(pressure))
    }
    
    func toGardenerTaskDoneByModel(_ task: [String: Any]?) -> TaskDoneBy? {
        if task != nil {
            let date = Date(timeIntervalSince1970: task![TasksConsts.Date] as? Double ?? 0)
            let userId = task![TasksConsts.UserId] as? String ?? ""
            return TaskDoneBy(userId: userId, date: date)
        } else {
            return nil
        }
    }
    
    
    func toGardenerTaskModel(_ taskPlant: [String: Any]) -> GardenerTasksPlantModel {
        let date = Date(timeIntervalSince1970: taskPlant[TasksConsts.Date] as? Double ?? 0)
        let dayFromPlantation = taskPlant[TasksConsts.DayFromPlantation] as? Int ?? 0
        let description = taskPlant[TasksConsts.Description] as? String ?? ""
        let done = taskPlant[TasksConsts.DoneInTime] as? Bool
        let title = taskPlant[TasksConsts.Title] as? String ?? ""
        let doneBy = toGardenerTaskDoneByModel(taskPlant[TasksConsts.DoneBy] as? [String:Any])
        let taskId = taskPlant[TasksConsts.TaskId] as? String ?? ""
        
        let doInTime = taskPlant[TasksConsts.DoInTime] as? String ?? ""
        let priority = taskPlant[TasksConsts.Priority] as? Int ?? 0
        let steps = toStepsTask(taskPlant[TasksConsts.Steps] as? [Any] ?? [])
        let url = taskPlant[TasksConsts.Url] as? String ?? ""
        
        let toolsDict = taskPlant[TasksConsts.Tools] as? [String: Any] ?? [:]
        let tools = toolsDict.map { $0.key }
        
        return GardenerTasksPlantModel(date: date, dayFromPlantation: dayFromPlantation, description: description, priority: priority, tools: tools, url: url, steps: steps, title: title, doneInTime: done, doInTime: doInTime, doneBy: doneBy, taskId: taskId)
    }
    
    func toStepsTask(_ taskSteps: [Any]) -> [GardenerTasksSteps] {
        var arrSteps: [GardenerTasksSteps] = []
        taskSteps.forEach {
            let steps = $0 as? [String: Any] ?? [:]
            let description = steps[TasksConsts.Description] as? String ?? ""
            let image = steps[TasksConsts.Image] as? String ?? ""
            let title = steps[TasksConsts.Title] as? String ?? ""
            arrSteps.append(GardenerTasksSteps(description: description, image: image, title: title))
        }
        return arrSteps
    }
    
    func toGardenerPlantModel(_ dictPlant: [String: Any]) -> GardenerPlantModel {
        let dateHarvested = Date(timeIntervalSince1970: dictPlant[PlantsConsts.DateHarvested] as? Double ?? 0)
        let dateSowing = Date(timeIntervalSince1970: dictPlant[PlantsConsts.DateSowing] as? Double ?? 0)
        let plantID = dictPlant[PlantsConsts.PlantID] as? String ?? ""
        let plantName = dictPlant[PlantsConsts.PlantName] as? String ?? ""
        let picture = dictPlant[PlantsConsts.Picture] as? Bool ?? false
        let tasksArray = dictPlant[PlantsConsts.Tasks] as? [Any] ?? []
        let status = dictPlant[PlantsConsts.Status] as? String ?? "unknown"
        return GardenerPlantModel(dateHarvested: dateHarvested, dateSowing: dateSowing, plantID: plantID, plantName: plantName, picture: picture, status: status, tasks: tasksArray)
    }
    
    func toOwnersModel(_ dictOwners: [String: Any]) -> [String] {
        var owners = dictOwners.map { $0.key }
        return owners
    }
    
    func toGardenerPlantTasks(_ tasksArray: [Any]) -> [Int: GardenerTasksPlantModel] {
        let tasksFormatted = Dictionary(uniqueKeysWithValues:
                                            tasksArray.enumerated().map { ($0, self.toGardenerTaskModel($1 as! [String: Any]))
        })
        return tasksFormatted
    }
    
    func toDictionaryToAddPlant(_ name: String, plantID: String) -> [String: Any] {
        return [
            PlantsConsts.PlantName: name,
            PlantsConsts.PlantID: plantID
        ]
    }
    
    func toDictionaryToAddPlantPreviousDate(_ name: String, plantID: String, previousDate: Int) -> [String: Any] {
        return [
            PlantsConsts.PlantName: name,
            PlantsConsts.PlantID: plantID,
            PlantsConsts.PreviousDate: previousDate
        ]
    }
    
    func toDictonaryPlantModel(_ gardenerPlantModel: GardenerPlantModel) -> [String: Any] {
        return [
            PlantsConsts.DateHarvested: gardenerPlantModel.dateHarvested,
            PlantsConsts.DateSowing: gardenerPlantModel.dateSowing,
            PlantsConsts.Picture: gardenerPlantModel.picture,
            PlantsConsts.PlantID: gardenerPlantModel.plantID,
            PlantsConsts.PlantName: gardenerPlantModel.plantName
        ]
    }
    
    func toDictonaryWishlistModel(_ wishlistModel: WishlistModel) -> [String: Any] {
        let plantingDict = self.toDictionnaryPlanting(plantingPeriod: wishlistModel.plantingPeriod)
        let sowingDict = self.toDictionnarySowing(sowingPeriod: wishlistModel.sowingPeriod)
        return [
            WishlistConsts.PlantingPeriod:  plantingDict,
            WishlistConsts.SowingPeriod: sowingDict
        ]
    }
    
    func toDictionnaryPlanting(plantingPeriod: PlantingPeriodModel) -> [String: Any] {
        return [
            WishlistConsts.StartMonth: plantingPeriod.startMonth,
            WishlistConsts.EndMonth: plantingPeriod.endMonth
        ]
    }
    
    func toDictionnarySowing(sowingPeriod: PlantSowingPeriodModel) -> [String: Any] {
        return [
            WishlistConsts.StartMonth: sowingPeriod.startMonth,
            WishlistConsts.GrowingTime: sowingPeriod.growingTime,
            WishlistConsts.EndMonth: sowingPeriod.endMonth
        ]
    }
    
    func toWishlistModel(_ wishlist: [String: Any]) -> [String: WishlistModel] {
        let wishlist = Dictionary(uniqueKeysWithValues: wishlist.map { ($0, self.toWishlistModelDetail($1 as! [String: Any], plantId: $0)) })
        return wishlist
    }
    
    func toWishlistModelDetail(_ model: [String: Any], plantId: String) -> WishlistModel {
        let sowingPeriodDict = model[WishlistConsts.SowingPeriod] as? [String: Any] ?? [:]
        let plantingPeriodDict = model[WishlistConsts.PlantingPeriod] as? [String: Any] ?? [:]
        return WishlistModel(plantId: plantId, sowingPeriod: self.toPlantSowingPeriodModel(sowingPeriodDict), plantingPeriod: self.toPlantPlantingPeriodModel(plantingPeriodDict))
    }
    
    func toFormatTask(_ tasks: [Any], stageAndRow: String, plantId: String, dateHarvested: Date, dateSowing: Date, plantName: String, picture: Bool, status: String) -> [GardenerTaskModelToAllTasks] {
        var gardenerTask: [GardenerTaskModelToAllTasks] = []
        tasks.enumerated().forEach { (index, task) in
            if let taskValue = task as? [String: Any] {
                gardenerTask.append(GardenerTaskModelToAllTasks(task: self.toGardenerTaskModel(taskValue), id: index, stageAndRow: stageAndRow, plantId: plantId, dateHarvested: dateHarvested, dateSowing: dateSowing, plantName: plantName, picture: picture, status: status))
            }
        }
        return gardenerTask
    }
    
    func toPlantPlantingPeriodModel(_ metaDict: [String: Any]) -> PlantingPeriodModel {
        let startMonth = metaDict[WishlistConsts.StartMonth] as? Int ?? 1
        let endMonth = metaDict[WishlistConsts.EndMonth] as? Int ?? 1
        return PlantingPeriodModel(endMonth: endMonth, startMonth: startMonth)
    }
    
    func toPlantSowingPeriodModel(_ metaDict: [String: Any]) -> PlantSowingPeriodModel {
        let startMonth = metaDict[WishlistConsts.StartMonth] as? Int ?? 1
        let endMonth = metaDict[WishlistConsts.EndMonth] as? Int ?? 1
        let growingTime = metaDict[WishlistConsts.GrowingTime] as? Int ?? 1
        return PlantSowingPeriodModel(endMonth: endMonth, startMonth: startMonth, growingTime: growingTime)
    }
    
    
    func toAllTasksWithManyPlants(_ plants: [String: Any]) -> [GardenerTaskModelToAllTasks] {
        let plantsFormated = plants.mapValues { self.toGardenerPlantModel($0 as! [String : Any]) }
        return plantsFormated.flatMap({ self.toFormatTask($0.value.tasks, stageAndRow: $0.key, plantId: $0.value.plantID, dateHarvested: $0.value.dateHarvested, dateSowing: $0.value.dateSowing, plantName: $0.value.plantName, picture: $0.value.picture, status: $0.value.status) })
    }
    
    func toAllTasksWithOnePlant(_ plant: [String: Any], stageAndRow: String) -> [GardenerTaskModelToAllTasks] {
        let gardenerPlantModel = self.toGardenerPlantModel(plant)
        return self.toFormatTask(gardenerPlantModel.tasks, stageAndRow: stageAndRow, plantId: gardenerPlantModel.plantID, dateHarvested: gardenerPlantModel.dateHarvested, dateSowing: gardenerPlantModel.dateSowing, plantName: gardenerPlantModel.plantName, picture: gardenerPlantModel.picture, status: gardenerPlantModel.status)
    }
    
    func toTipsModel(_ tipsAlert: [String: Any]) -> TipsModel {
        let battery = tipsAlert[TipsConst.Battery] as? Bool ?? false
        let soilMisture = tipsAlert[TipsConst.SoilMisture] as? Bool ?? false
        let solarPower = tipsAlert[TipsConst.SolarPower] as? Bool ?? false
        let temperature = tipsAlert[TipsConst.Temperature] as? Bool ?? false
        let waterLevel = tipsAlert[TipsConst.WaterLevel] as? Bool ?? false
        let wind = tipsAlert[TipsConst.Wind] as? Bool ?? false
        let luminosity = tipsAlert[TipsConst.Luminosity] as? Bool ?? false
        return TipsModel(soilMisture: soilMisture, battery: battery, waterLevel: waterLevel, temperature: temperature, luminosity: luminosity)
    }
    
    func toGardenerClassic(_ classicGardener: ClassicGardener) -> [String : Any] {
        return [
            GardenerConsts.IsPublic: classicGardener.ispublic,
            GardenerConsts.Owners: classicGardener.owners,
            GardenerConsts.Metadata: [
                Consts.Address: classicGardener.metadata.address,
                Consts.Name: classicGardener.metadata.name,
                Consts.City: classicGardener.metadata.city,
                GardenerConsts.SunPosition: classicGardener.metadata.ensoleillement,
                GardenerConsts.Placement: classicGardener.metadata.emplacement,
                GardenerConsts.ZipCode: classicGardener.metadata.zipCode,
                GardenerConsts.CountryCode: classicGardener.metadata.countryCode
            ],
            GardenerConsts.GardenerType: classicGardener.type,
            GardenerConsts.Stage: classicGardener.stage,
            GardenerConsts.Dimension: classicGardener.dimension
        ]
    }
    
    func toGardenerParcelle(_ parcelleGardener: ParcelleGardener,_ gardenerRef: String) -> [String : Any] {
        return [
            GardenerConsts.IsPublic: parcelleGardener.ispublic,
            GardenerConsts.Owners: parcelleGardener.owners,
            GardenerConsts.Metadata: [
                Consts.Address: parcelleGardener.metadata.address,
                Consts.Name: parcelleGardener.metadata.name,
                Consts.City: parcelleGardener.metadata.city,
                GardenerConsts.SunPosition: parcelleGardener.metadata.ensoleillement,
                GardenerConsts.Placement: parcelleGardener.metadata.emplacement
            ],
            GardenerConsts.GardenerType: parcelleGardener.type,
            GardenerConsts.Stage: parcelleGardener.stage,
            GardenerConsts.Dimension: parcelleGardener.dimension,
            GardenerConsts.GardenerParent: gardenerRef
        ]
    }
}

protocol GardenerRepository {
    func getRootReference() -> DatabaseReference
    func getReference(for key: String) -> DatabaseReference
    func getReferenceTest(for key: Any) -> DatabaseReference
    func getClimatReference(_ ownerUID: String) -> DatabaseReference
    func getMetadataReference(for key: String) -> DatabaseReference
    func getGardenersOwnersRef(by gardenerId: String) -> DatabaseReference
    func getGardenerFriendsReference(for key: String) -> DatabaseReference
    func getGardenersFriendsRef(by gardenerId: String) -> DatabaseReference
    func getMetadataImagesReference(by gardernerId: String) -> DatabaseReference
    func getGardenerStatsReference(for key: String) -> DatabaseReference
    func getAllPlantsReference(by gardenerId: String) -> DatabaseReference
    func getWishlistReference(by gardenerId: String) -> DatabaseReference
    func getPlantStageAndRowPictureReference(by gardenerId: String, by key: String) -> DatabaseReference
    func getPlantStageAndRowReference(by gardenerId: String, by key: String) -> DatabaseReference
    func getPlantsToAdd(by gardenerId: String, by key: String) -> DatabaseReference
    func getPlantingToAdd(by gardenerId: String, by key: String) -> DatabaseReference
    func getPlantingToAddPreviousDate(by gardenerId: String, by key: String) -> DatabaseReference
    func getPlantStageAndRowTaskDoneInTimeReference(by gardenerId: String, by key: String, id: String) -> DatabaseReference
    func getPlantStageAndRowTaskDoneReference(by gardenerId: String, by key: String, id: String) -> DatabaseReference
    func getPlantStageAndRowTaskSetDoneByReference(by gardenerId: String, by key: String, id: String) -> DatabaseReference
    func getPlantStageAndRowAllTaskReference(by gardenerId: String, by key: String) -> DatabaseReference
    func getGardenerTipsReference(by gardenerId: String) -> DatabaseReference
    
    func getStorageGardenerPicturesRef(by gardernerId: String) -> StorageReference
    func getStorageStepTask(_ id: String, _ stepName: String) -> StorageReference
    func getGardenerImage(by gardenerId: String, name: String) -> StorageReference
    func getGardenerPlantStageAndRowStorage(by gardenerId: String, by stageAndRow: String) -> StorageReference
    func getGardenerIsPublicReference(by gardenerId: String) -> DatabaseReference
    func getGardenerSubscribeMemberReference(by gardenerId: String) -> DatabaseReference
    func getGardenerSubscribeMemberWithIdReference(by gardenerId: String, userId: String) -> DatabaseReference
    
    func removePlant(by gardenerId: String, by key: String) -> DatabaseReference
    func getGardenerStages(by gardenerId: String) -> DatabaseReference
    //TODO: TO VERIF
    func getGardenerIrrigationRef(by gardenerId: String) -> DatabaseReference
}

class GardenerRepositoryImpl: GardenerRepository {
    
    private var rootReference: DatabaseReference {
        return Database.database().reference(withPath: GardenerConsts.RootNode)
    }
    func getRootReference() -> DatabaseReference {
        return rootReference
    }
    
    func getClimatReference(_ ownerUID: String) -> DatabaseReference {
        return rootReference.child(ownerUID).child(GardenerConsts.Climat)
    }
    
    private var rootStorageReference: StorageReference {
        return Storage.storage().reference(withPath: GardenerConsts.RootNode)
    }
    
    
    private var rootStepStorageReference: StorageReference {
        return Storage.storage().reference(withPath: GardenerConsts.Plants)
    }
    
    func getReference(for key: String) -> DatabaseReference {
        return rootReference.child(key)
    }
    
    func getReferenceTest(for key: Any) -> DatabaseReference {
        print("mon id : \(key)")
        print("ma reference nop : \(rootReference.child("2F%20C4AC590000CC8AJP"))")
        print("ma reference yes : \(rootReference.child("3132373752377904"))")
        return rootReference.child(key as! String)
    }
    
    func getMetadataReference(for key: String) -> DatabaseReference {
        return getReference(for: key).child(GardenerConsts.Metadata)
    }
    
    func getGardenersOwnersRef(by key: String) -> DatabaseReference {
        return getReference(for: key).child(GardenerConsts.Owners)
    }
    
    func getGardenerFriendsReference(for key: String) -> DatabaseReference {
        return getReference(for: key).child(GardenerConsts.Friends)
    }
    
    func getGardenersFriendsRef(by gardenerId: String) -> DatabaseReference {
        return rootReference.child(gardenerId).child(GardenerConsts.Friends)
    }
    
    func getMetadataImagesReference(by gardenerId: String) -> DatabaseReference {
        return getReference(for: gardenerId).child(GardenerConsts.Metadata).child(GardenerConsts.Images)
    }
    
    func getGardenerStatsReference(for key: String) -> DatabaseReference {
        return getReference(for: key).child(GardenerConsts.Stats)
    }
    
    func getAllPlantsReference(by gardenerId: String) -> DatabaseReference {
        return getReference(for: gardenerId).child(GardenerConsts.Plants)
    }
    
    func getWishlistReference(by gardenerId: String) -> DatabaseReference {
        return getReference(for: gardenerId).child(GardenerConsts.Wishlist)
    }
    
    func getPlantStageAndRowPictureReference(by gardenerId: String, by key: String) -> DatabaseReference {
        return getReference(for: gardenerId).child(GardenerConsts.Plants).child(key).child(PlantsConsts.Picture)
    }
    
    func getPlantStageAndRowReference(by gardenerId: String, by key: String) -> DatabaseReference {
        return getReference(for: gardenerId).child(GardenerConsts.Plants).child(key)
    }
    
    func getPlantsToAdd(by gardenerId: String, by key: String) -> DatabaseReference {
        return getReference(for: gardenerId).child(GardenerConsts.PlantsToAdd).child(key)
    }
    
    func getPlantingToAdd(by gardenerId: String, by key: String) -> DatabaseReference {
        return getReference(for: gardenerId).child(GardenerConsts.PlantingToAdd).child(key)
    }
    
    func getPlantingToAddPreviousDate(by gardenerId: String, by key: String) -> DatabaseReference {
        return getReference(for: gardenerId).child(GardenerConsts.PlantingToAddPreviousDate).child(key)
    }
    
    func getPlantStageAndRowTaskDoneInTimeReference(by gardenerId: String, by key: String, id: String) -> DatabaseReference {
        return getReference(for: gardenerId).child(GardenerConsts.Plants).child(key).child(PlantsConsts.Tasks).child(id).child(TasksConsts.DoneInTime)
    }
    
    func getPlantStageAndRowTaskDoneReference(by gardenerId: String, by key: String, id: String) -> DatabaseReference {
        return getReference(for: gardenerId).child(GardenerConsts.Plants).child(key).child(PlantsConsts.Tasks).child(id).child(TasksConsts.Done)
    }
    
    func getPlantStageAndRowTaskSetDoneByReference(by gardenerId: String, by key: String, id: String) -> DatabaseReference {
        return getReference(for: gardenerId).child(GardenerConsts.Plants).child(key).child(PlantsConsts.Tasks).child(id).child(TasksConsts.DoneBy)
    }
    
    func getPlantStageAndRowAllTaskReference(by gardenerId: String, by key: String) -> DatabaseReference {
        return getReference(for: gardenerId).child(GardenerConsts.Plants).child(key).child(PlantsConsts.Tasks)
    }
    
    func getGardenerTipsReference(by gardenerId: String) -> DatabaseReference {
        return getReference(for: gardenerId).child(GardenerConsts.Tips)
    }
    
    func getGardenerIsPublicReference(by gardenerId: String) -> DatabaseReference {
        return getReference(for: gardenerId).child(GardenerConsts.IsPublic)
    }
    //TODO: TO VERIF
    func getGardenerIrrigationRef(by gardenerId: String) ->
    DatabaseReference {
        return getReference(for: gardenerId).child(GardenerConsts.Irrigation)
    }
    
    func getGardenerSubscribeMemberReference(by gardenerId: String) -> DatabaseReference {
        return getReference(for: gardenerId).child(GardenerConsts.SubscribeMember)
    }
    
    func getGardenerSubscribeMemberWithIdReference(by gardenerId: String, userId: String) -> DatabaseReference {
        return getReference(for: gardenerId).child(GardenerConsts.SubscribeMember).child(userId)
    }
    
    func getStorageGardenerPicturesRef(by gardernerId: String) -> StorageReference {
        return rootStorageReference.child(gardernerId)
    }
    
    func getStorageStepTask(_ id: String, _ stepName: String) -> StorageReference {
        return rootStepStorageReference.child(id).child(GardenerConsts.StepNode).child( stepName + ".jpg")
    }
    
    func getGardenerImage(by gardenerId: String, name: String) -> StorageReference {
        return rootStorageReference.child(gardenerId).child(name)
    }
    
    func getGardenerPlantStageAndRowStorage(by gardenerId: String, by stageAndRow: String) -> StorageReference {
        return rootStorageReference.child(gardenerId).child(stageAndRow).child(GardenerConsts.plantImage)
    }
    
    func removePlant(by gardenerId: String, by key: String) -> DatabaseReference {
        return getReference(for: gardenerId).child(GardenerConsts.Plants).child(key)
    }
    
    func getGardenerStages(by gardenerId: String) -> DatabaseReference {
        return getReference(for: gardenerId).child(GardenerConsts.Stage)
    }
}

struct TaskDoneBy {
    let userId: String
    let date: Date
}

struct GardenerTasksSteps {
    let description: String
    let image: String
    let title: String
}

struct GardenerTasksPlantModel {
    let date: Date
    let dayFromPlantation: Int
    let description: String
    let priority: Int
    let tools: [String]
    let url: String
    let steps: [GardenerTasksSteps]
    let title: String
    let doneInTime: Bool?
    let doInTime: String
    let doneBy: TaskDoneBy?
    let taskId: String?
}

struct GardenerPlantModel {
    let dateHarvested: Date
    let dateSowing: Date
    let plantID: String
    let plantName: String
    let picture: Bool
    let status: String
    let tasks: [Any]
}

struct WishlistModel {
    let plantId: String
    let sowingPeriod: PlantSowingPeriodModel
    let plantingPeriod: PlantingPeriodModel
}

struct GardenerClimatModel {
    let temperature: Int
    let wind: Int
    let humidity: Int
    let luminosity: Int
}

/*struct GardenerStatsModelNew {
    let battery: Int
    let waterLevel: Int
    let soilMisture: Int
    //let solarPower: Int
    //let airHumidity: Int
    let temperature: Int
    let humidity: Int
    // adison udpdate
    let luminosity: Int
    let pressure: Int
}*/

struct GardenerStatsModelNew {
    let battery: Int
    let waterLevel: Int
    let temperature: Int
    let humidity: Int
    let capacities: Capacities
    let luminosity: Int
    let pressure: Int
}

struct TipsModel {
    let soilMisture: Bool
    //let solarPower: Bool
    let battery: Bool
    let waterLevel: Bool
    let temperature: Bool
    //let wind: Bool
    // adison update
    let luminosity: Bool
}

struct Capacities {
    let c1: Int
    let c2: Int
    let c3: Int
    let c4: Int
    let c5: Int
}

struct GardenerModel {
    let id: String
    var metadata: GardenerMetadataModel
    let climat: GardenerClimatModel
    let stats: GardenerStatsModelNew
    let friends: [String: Any]
    let owner: String
    let owners: [String: Any]
    let wishlist: [String: WishlistModel]
    let invitation: String
    let tips: TipsModel
    let taskPlants: [GardenerTaskModelToAllTasks]
    let stage: String
    let ispublic: Bool
    let subcribemember: [String: Any]
    let type: String
    let dimension: Int
    let gardenerParent: String
    let loraTs: String
    let rangs: Int
    let irrigation: Irrigation
}

struct GardenerMetadataModel {
    var name: String
    let city: String
    let address: String
    let zipCode: String
    let images: [String: Any]
    let emplacement: Int
    let ensoleillement: Int
    let orientation: Int
    let countryCode: String
}

struct GardenerTaskModelToAllTasks {
    let task: GardenerTasksPlantModel
    let id: Int
    let stageAndRow: String
    let plantId: String
    let dateHarvested: Date
    let dateSowing: Date
    let plantName: String
    let picture: Bool
    let status: String
}

struct FriendImages {
    let gardenerId: String
    let ownerId: String
    var user: UserModel?
}

struct ImagesGardener {
    let gardenerId: String
    let imageId: String
    let gardenerName: String
    let hasLogo: Bool
}


struct GardenerTypeStruct {
    let type: String
    let title: String
    let desc: String
    let image: String
}

struct SpecificTypeStructValue {
    let type: SizeSelectingType
    let image: String
    let text: String
    let desc: String
}

struct SelectingTypeStruct {
    let type: String
    let image: String
    let text: String
}

struct ClassicGardener {
    var ispublic = false
    var stage = ""
    var metadata = GardenerMetadataModel(name: "", city: "", address: "", zipCode: "13000", images: [:], emplacement: 0, ensoleillement: 0, orientation: 0, countryCode: "fr")
    var owners : [String:Bool] = [:]
    var type = ""
    var dimension = -1
}

struct ParcelleGardener {
    var ispublic = false
    var stage = 4
    var rangs = 2
    var metadata = GardenerMetadataModel(name: "", city: "", address: "", zipCode: "13000", images: [:], emplacement: 0, ensoleillement: 0, orientation: 0, countryCode: "fr")
    var owners : [String:Bool] = [:]
    var type = "parcelle"
    var dimension = -1
}


