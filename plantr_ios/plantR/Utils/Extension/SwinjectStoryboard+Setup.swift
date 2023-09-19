//
//  SwinjectStoryboard+Setup.swift
//  plantR_ios
//
//  Created by Rabissoni on 22/01/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import SwinjectStoryboard
import Firebase

extension SwinjectStoryboard {
    
    class func moreSetupInjec() {
        defaultContainer.storyboardInitCompleted(FormGardenerVC.self) { r, c in
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
            c.gardenerRepository = r.resolve(GardenerRepository.self)
            c.userRepository = r.resolve(UserRepository.self)
            c.userTransformer = r.resolve(UserTransformer.self)
        }
        defaultContainer.storyboardInitCompleted(FormJumelageGardenerVC.self) { r, c in
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
            c.gardenerRepository = r.resolve(GardenerRepository.self)
            c.userRepository = r.resolve(UserRepository.self)
            c.userTransformer = r.resolve(UserTransformer.self)
        }
        defaultContainer.storyboardInitCompleted(NewTaskDetailVC.self) { r, c in
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
            c.gardenerRepository = r.resolve(GardenerRepository.self)
            c.userRepository = r.resolve(UserRepository.self)
            c.userTransformer = r.resolve(UserTransformer.self)
            c.plantRepository = r.resolve(PlantRepository.self)
            c.plantsService = r.resolve(PlantsService.self)
        }
        defaultContainer.storyboardInitCompleted(WishlistPositionPlantVC.self) { r, c in
            c.gardenerRepository = r.resolve(GardenerRepository.self)
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
            c.plantsService = r.resolve(PlantsService.self)
        }
        defaultContainer.storyboardInitCompleted(AddToFollowVC.self) { r, c in
            c.userRepository = r.resolve(UserRepository.self)
            c.userTransformer = r.resolve(UserTransformer.self)
            c.gardenerRepository = r.resolve(GardenerRepository.self)
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
        }
        defaultContainer.storyboardInitCompleted(SelectDateAlreadyPlantVC.self) { r, c in
            c.gardenerRepository = r.resolve(GardenerRepository.self)
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
        }

        defaultContainer.storyboardInitCompleted(SubscribeMemberTeamCV.self) { r, c in
            c.userRepository = r.resolve(UserRepository.self)
            c.userTransformer = r.resolve(UserTransformer.self)
            c.gardenerRepository = r.resolve(GardenerRepository.self)
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
        }
        defaultContainer.storyboardInitCompleted(MyTeamVC.self) { r, c in
            c.userRepository = r.resolve(UserRepository.self)
            c.userTransformer = r.resolve(UserTransformer.self)
            c.gardenerRepository = r.resolve(GardenerRepository.self)
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
        }
        defaultContainer.storyboardInitCompleted(NewGardenerOwnerVC.self) { r, c in
            c.userRepository = r.resolve(UserRepository.self)
            c.userTransformer = r.resolve(UserTransformer.self)
            c.gardenerRepository = r.resolve(GardenerRepository.self)
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
        }
        defaultContainer.storyboardInitCompleted(SubscribeDetailVC.self){ r, c in
            c.gardenerRepository = r.resolve(GardenerRepository.self)
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
            c.plantsService = r.resolve(PlantsService.self)
        }
        defaultContainer.storyboardInitCompleted(TaskDetailDoneVC.self) { r, c in
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
            c.gardenerRepository = r.resolve(GardenerRepository.self)
            c.userRepository = r.resolve(UserRepository.self)
            c.userTransformer = r.resolve(UserTransformer.self)
            c.plantRepository = r.resolve(PlantRepository.self)
            c.plantsService = r.resolve(PlantsService.self)
        }
        defaultContainer.storyboardInitCompleted(TaskDetailNotificationVC.self) { r, c in
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
            c.gardenerRepository = r.resolve(GardenerRepository.self)
            c.userRepository = r.resolve(UserRepository.self)
            c.userTransformer = r.resolve(UserTransformer.self)
            c.plantRepository = r.resolve(PlantRepository.self)
        }
        defaultContainer.storyboardInitCompleted(ChoiceCategoriePlantsVC.self)  { r, c in
            c.plantRepository = r.resolve(PlantRepository.self)
            c.plantsService = r.resolve(PlantsService.self)
        }
        defaultContainer.storyboardInitCompleted(WishlistVC.self)  { r, c in
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
            c.gardenerRepository = r.resolve(GardenerRepository.self)
            c.plantsService = r.resolve(PlantsService.self)
        }
        defaultContainer.storyboardInitCompleted(IrrigVC.self) { r, c in
            c.userTransformer = r.resolve(UserTransformer.self)
            c.userRepository = r.resolve(UserRepository.self)
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
            c.gardenerRepository = r.resolve(GardenerRepository.self)
        }
    }
    class func setup() {
        defaultContainer.storyboardInitCompleted(SplashVC.self) { (r, c) in
            c.userRepository = r.resolve(UserRepository.self)
            c.userTransformer = r.resolve(UserTransformer.self)
            c.plantsService = r.resolve(PlantsService.self)
        }
        defaultContainer.storyboardInitCompleted(SignUpVC.self) { r, c in
            c.userTransformer = r.resolve(UserTransformer.self)
            c.userRepository = r.resolve(UserRepository.self)
        }
        defaultContainer.storyboardInitCompleted(AccountVC.self) { r, c in
            c.userTransformer = r.resolve(UserTransformer.self)
            c.userRepository = r.resolve(UserRepository.self)
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
            c.gardenerRepository = r.resolve(GardenerRepository.self)
            c.avatarService = r.resolve(AvatarService.self)
        }
        defaultContainer.storyboardInitCompleted(MenuVC.self) { r, c in
            c.userTransformer = r.resolve(UserTransformer.self)
            c.userRepository = r.resolve(UserRepository.self)
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
            c.gardenerRepository = r.resolve(GardenerRepository.self)
        }
        defaultContainer.storyboardInitCompleted(SubscribeVC.self) { r, c in
            c.userTransformer = r.resolve(UserTransformer.self)
            c.userRepository = r.resolve(UserRepository.self)
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
            c.gardenerRepository = r.resolve(GardenerRepository.self)
        }
        defaultContainer.storyboardInitCompleted(AddNewFriendVC.self) { r, c in
            c.userTransformer = r.resolve(UserTransformer.self)
            c.userRepository = r.resolve(UserRepository.self)
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
            c.gardenerRepository = r.resolve(GardenerRepository.self)
        }
        defaultContainer.storyboardInitCompleted(AddPlantSearchVC.self) { (r, c) in
            c.plantsService = r.resolve(PlantsService.self)
        }
        defaultContainer.storyboardInitCompleted(PlantRVC.self) { r, c in
            c.userTransformer = r.resolve(UserTransformer.self)
            c.userRepository = r.resolve(UserRepository.self)
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
            c.gardenerRepository = r.resolve(GardenerRepository.self)
            c.getWeather = r.resolve(GetWeather.self)
            c.tipsService = r.resolve(TipsService.self)
        }
        defaultContainer.storyboardInitCompleted(PlantsVC.self) { r, c in
            c.userTransformer = r.resolve(UserTransformer.self)
            c.userRepository = r.resolve(UserRepository.self)
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
            c.gardenerRepository = r.resolve(GardenerRepository.self)
            c.plantsService = r.resolve(PlantsService.self)
        }
        defaultContainer.storyboardInitCompleted(InfoPlantMyPlantsVC.self) { r, c in
            c.plantsService = r.resolve(PlantsService.self)
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
            c.gardenerRepository = r.resolve(GardenerRepository.self)
        }
        defaultContainer.storyboardInitCompleted(AddPlantsVC.self) { r, c in
            c.plantsService = r.resolve(PlantsService.self)
        }
        defaultContainer.storyboardInitCompleted(ChangeNameVC.self) { r, c in
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
            c.gardenerRepository = r.resolve(GardenerRepository.self)
        }
        defaultContainer.storyboardInitCompleted(AllTasksVC.self) { r, c in
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
            c.gardenerRepository = r.resolve(GardenerRepository.self)
        }
        defaultContainer.storyboardInitCompleted(TaskDetailVC.self) { r, c in
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
            c.gardenerRepository = r.resolve(GardenerRepository.self)
            c.userTransformer = r.resolve(UserTransformer.self)
            c.userRepository = r.resolve(UserRepository.self)
            c.plantRepository = r.resolve(PlantRepository.self)
            c.plantsService = r.resolve(PlantsService.self)
        }
        defaultContainer.storyboardInitCompleted(TasksVC.self) { r, c in
            c.userTransformer = r.resolve(UserTransformer.self)
            c.userRepository = r.resolve(UserRepository.self)
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
            c.gardenerRepository = r.resolve(GardenerRepository.self)
            c.plantsService = r.resolve(PlantsService.self)
        }
        defaultContainer.storyboardInitCompleted(TipsDetailVC.self) { r, c in
            c.gardenerRepository = r.resolve(GardenerRepository.self)
            c.tipsService = r.resolve(TipsService.self)
        }
        defaultContainer.storyboardInitCompleted(SettingNameGardenerVC.self) { r, c in
            c.gardenerRepository = r.resolve(GardenerRepository.self)
            c.gardenerTransformer = r.resolve(GardenerTransformer.self)
        }
        defaultContainer.storyboardInitCompleted(SettingCityGardenerVC.self) { r, c in
                   c.gardenerRepository = r.resolve(GardenerRepository.self)
                   c.gardenerTransformer = r.resolve(GardenerTransformer.self)
               }
        defaultContainer.storyboardInitCompleted(ScannerVC.self) { r, c in
                   c.userRepository = r.resolve(UserRepository.self)
                   c.userTransformer = r.resolve(UserTransformer.self)
                   c.gardenerRepository = r.resolve(GardenerRepository.self)
                   c.gardenerTransformer = r.resolve(GardenerTransformer.self)
               }
        moreSetupInjec()

        defaultContainer.register(UserTransformer.self) { _ in UserTransformerImpl() }.inObjectScope(.container)
        defaultContainer.register(UserRepository.self) { _ in UserRepositoryImpl() }.inObjectScope(.container)
        defaultContainer.register(GardenerTransformer.self) { _ in GardenerTransformerImpl() }.inObjectScope(.container)
        defaultContainer.register(GardenerRepository.self) { _ in GardenerRepositoryImpl() }.inObjectScope(.container)
        defaultContainer.register(AvatarService.self) { r in
            AvatarService(userRepository: r.resolve(UserRepository.self)!)
        }.inObjectScope(.container)
        defaultContainer.register(TipsService.self) { r in
            TipsService(gardenerRepository: r.resolve(GardenerRepository.self)!)
        }.inObjectScope(.container)
        defaultContainer.register(PlantTransformer.self) { _ in PlantTransformerImpl() }.inObjectScope(.container)
        defaultContainer.register(PlantRepository.self) { _ in PlantRepositoryImpl() }.inObjectScope(.container)
        defaultContainer.register(PlantsService.self) {  r in
            PlantsService(plantRepository: r.resolve(PlantRepository.self)!, plantTransformer: r.resolve(PlantTransformer.self)!)
        }.inObjectScope(.container)
        defaultContainer.register(GetWeather.self) { _ in GetWeather() }.inObjectScope(.container)
        defaultContainer.register(BLESettings.self) { _ in BLESettings() }
    }
}
