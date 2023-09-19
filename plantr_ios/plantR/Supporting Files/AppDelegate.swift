//
//  AppDelegate.swift
//  plantR_ios
//
//  Created by Rabissoni on 17/01/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import RGPD
import Branch
import UserNotifications

enum BranchLinkType: String {
    case goToOwner = "goToOwner"
    case goToGuest = "goToGuest"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var uidFromBranch = ""
    
    var presentedViewController: UIViewController? {
        
        if let window = self.window, let rootVC = window.rootViewController {
            var presentedVC = rootVC
            while let presentedController = presentedVC.presentedViewController {
                presentedVC = presentedController
            }
            return presentedVC
        }
        return nil
    }
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        FirebaseApp.configure()
        RGPD.shared.configure(applicationBundleId: Bundle.main.bundleIdentifier!)
        setupNotifications(application: application)
        Messaging.messaging().delegate = self
        setupBranch(launchOptions: launchOptions)
        print("toro")
        if let remoteNotification = launchOptions?[.remoteNotification] as?  [AnyHashable : Any] {
            NotificationService.shared.object = remoteNotification
            
            let notif = NotificationService()
            if let type = remoteNotification["type"] as? String {
                notif.setAlertNotification(type: type)
            }
/*          if let type = remoteNotification["type"] as? String {
                switch type {
                case "taskDone":
                    if let plantUID = remoteNotification["plantUID"] as? String, let stage = remoteNotification["stage"] as? String, let gardenerId = remoteNotification["gardenerId"] as? String, let taskName = remoteNotification["taskName"] as? String, let taskId = remoteNotification["taskId"] as? String {
                        print("GO TO SHOW TASK")
                    }
                default:
                    break
                }
            }*/
        }
        return true
    }
    
    func setupNotifications(application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        center.requestAuthorization(options: options) { (didAllow, error) in
            if !didAllow {
                print("$$$$$$$$$$$$ NOT ALLLOW AUTHORISATION $$$$$$$$$$$")
            } else {
                DispatchQueue.main.async {
                    print("REGISTER TO REMOTE NOTIFIATIONS")
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func setupBranch(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        Branch.setUseTestBranchKey(false)
        let branchInstance = Branch.getInstance()
        
        branchInstance.initSession(launchOptions: launchOptions) { params, error in
            print(params)
            if error == nil, let params = params, params["+clicked_branch_link"] != nil, let type = params["type"] as? String, let name = params["name"] as? String {
                print("********** RENTRER **********")
                guard let presentedVC = self.presentedViewController else { return }
                let branchType = BranchLinkType.init(rawValue: type)
                switch branchType {
                case .goToOwner:
                    self.uidFromBranch = (params["gardenerId"] as? String) ?? ""
                    var user = Auth.auth().currentUser
                    if user != nil {
                        print("ICI")
                        BranchService.shared.branchGoToOwner = true
                        BranchService.shared.branchId = self.uidFromBranch
                        BranchService.shared.gardenerName = name
                        print("NAME => \(name)")
                        if let controller = UIStoryboard(name: "PopUpBranch", bundle: nil).instantiateInitialViewController() as? PopVC {
                            presentedVC.modalPresentationStyle = .fullScreen
                            presentedVC.present(controller, animated: true, completion: nil)
                        }
                    }
                default:
                    return
                }
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
        
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            return .landscape
        } else {
            return .portrait
        }
    }
    
    
    func showTask(plantUID: String, stage: String, gardenerId: String, taskName: String, taskId: String) {
        let controller = StoryboardScene.TasksAndTips.newTaskDetailVC.instantiate()
        
        controller.notification = true
        controller.gardenerId = gardenerId
        controller.taskName = taskName
        controller.stage = stage
        controller.plantUID = plantUID
        controller.taskId = taskId
        
        self.window?.rootViewController?.presentedViewController?.present(controller, animated: true, completion: nil)
    }
    
    func showGardener(gardenerId: String){
        //self.window?.rootViewController?.perform(segue: StoryboardSegue.Splash.goToHome)
    }
    
    
}


extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("FCM TOKEN", fcmToken)
        
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        completionHandler()

    }
    
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("toro")
        let notif = NotificationService()
        print("Received: \(userInfo)")
        switch application.applicationState {
        case UIApplication.State.active:
            print("ACTIVE NOTIFICATION")
            let badge = UIApplication.shared.applicationIconBadgeNumber
            UIApplication.shared.applicationIconBadgeNumber = badge + 1
            if let type = userInfo["type"] as? String {
                notif.setAlertNotification(type: type)
                if(userInfo["gardenerId"] as? String != nil){
                    showGardener(gardenerId: (userInfo["gardenerId"] as? String)!)
                }
            }
//            if let type = userInfo["type"] as? String {
//                switch type {
//                case "taskDone":
//                    print("active")
//                    if let plantUID = userInfo["plantUID"] as? String, let stage = userInfo["stage"] as? String, let gardenerId = userInfo["gardenerId"] as? String, let taskName = userInfo["taskName"] as? String, let taskId = userInfo["taskId"] as? String {
//                        print("GO TO SHOW TASK")
                //showTask(plantUID: plantUID, stage: stage, gardenerId: gardenerId, taskName: taskName, taskId: taskId)
//                    }
//                default:
//                    var notif = NotificationService()
//                    notif.setNotification(title: "bonjour", desc: "vous avez une notification")
//                    return
//                }
//            }
        case UIApplication.State.inactive:
            print("INACTIVE NOTIFICATION")
            let badge = UIApplication.shared.applicationIconBadgeNumber
            UIApplication.shared.applicationIconBadgeNumber = badge + 1
            var notif = NotificationService()
            if let type = userInfo["type"] as? String {
                notif.setAlertNotification(type: type)
                if(userInfo["gardenerId"] as? String != nil){
                    showGardener(gardenerId: (userInfo["gardenerId"] as? String)!)
                }
            }
//            if let type = userInfo["type"] as? String {
//                switch type {
//                case "taskDone":
//                    print("inactive")
//                    if let plantUID = userInfo["plantUID"] as? String, let stage = userInfo["stage"] as? String, let gardenerId = userInfo["gardenerId"] as? String, let taskName = userInfo["taskName"] as? String, let taskId = userInfo["taskId"] as? String {
//                        print("GO TO SHOW TASK")
//                        showTask(plantUID: plantUID, stage: stage, gardenerId: gardenerId, taskName: taskName, taskId: taskId)
//                    }
//                default:
//                    var notif = NotificationService()
//                    notif.setNotification(title: "bonjour", desc: "vous avez une notification")
//                    return
//                }
//            }
        case UIApplication.State.background:
            print("BACKGROUND NOTIFICATION")
            let badge = UIApplication.shared.applicationIconBadgeNumber
            UIApplication.shared.applicationIconBadgeNumber = badge + 1
            var notif = NotificationService()
            if let type = userInfo["type"] as? String {
                notif.setAlertNotification(type: type)
                if(userInfo["gardenerId"] as? String != nil){
                    showGardener(gardenerId: (userInfo["gardenerId"] as? String)!)
                }
            }
//            if let type = userInfo["type"] as? String {
//                switch type {
//                case "taskDone":
//                    if let plantUID = userInfo["plantUID"] as? String, let stage = userInfo["stage"] as? String, let gardenerId = userInfo["gardenerId"] as? String, let taskName = userInfo["taskName"] as? String, let taskId = userInfo["taskId"] as? String {
//                        showTask(plantUID: plantUID, stage: stage, gardenerId: gardenerId, taskName: taskName, taskId: taskId)
//
//                    }
///*                    if let plantUID = userInfo["plantUID"] as? String, let stage = userInfo["stage"] as? String, let gardenerId = userInfo["gardenerId"] as? String, let taskName = userInfo["taskName"] as? String, let taskId = userInfo["taskId"] as? String {
//                        print("GO TO SHOW TASK")
//                        showTask(plantUID: plantUID, stage: stage, gardenerId: gardenerId, taskName: taskName, taskId: taskId)
//                    }*/
//                default:
//                    var toto = NotificationService()
//                    toto.setNotification(title: "bonjour", desc: "vous avez une notification")
//                    return
//                }
//
//            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        //FirebaseMessaging.messaging().subscribeToTopic("toto")
    }
    
    
    
    
    
    
}
