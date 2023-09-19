//
//  NotificationService.swift
//  plantR_ios
//
//  Created by Boris Roussel on 27/11/2020.
//  Copyright © 2020 Agrove. All rights reserved.
//

import Foundation
import UIKit

class NotificationService {
    
    static let TuesdayNotification = "TuesdayNotification"
    static let FridayNotification = "FridayNotification"
    static let shared = NotificationService()
    
    var object: [AnyHashable : Any]?
    
    func setNotificationEveryWednesdayMorning() {
        let content = UNMutableNotificationContent()
        content.title = "Rappel"
        content.body = "Pensez à vérifier que vos plantes n'ont besoin de rien en ce moment ! 🌱"
        var dateComponents = DateComponents()
        content.sound = UNNotificationSound.default
        dateComponents.calendar = Calendar.current
        dateComponents.weekday = 4
        dateComponents.hour = 11
        dateComponents.minute = 30
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents, repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content, trigger: trigger)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if error != nil {
                print("ERROR ON SET NOTIFICATION")
            }
        }
    }
    
    func setNotification(title: String, desc: String) {
        //let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = desc
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                        repeats: false)

        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content, trigger: trigger)


        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if error != nil {
                print("ERROR ON SET NOTIFICATION")
            }
        }
    }
    
    func setAlertNotification(type: String){
        print("toro => \(type)")
        switch type {
        case "Battery":
            setNotification(title: NSLocalizedString("notif_battery", comment: "notif_battery"), desc: NSLocalizedString("notif_battery_desc", comment: "batery"))
        case "Waterlevel":
            setNotification(title: NSLocalizedString("notif_tank", comment: "notif"), desc: NSLocalizedString("notif_tank_desc", comment: "tank"))
        case "Capa":
            setNotification(title: NSLocalizedString("notif_humidity", comment: "notif_humidity"), desc: NSLocalizedString("notif_humidity_desc", comment: "humidity"))
        case "LoraTs":
            setNotification(title: NSLocalizedString("notif_problem", comment: "problem"), desc: NSLocalizedString("notif_problem_desc", comment: "problem"))
        default:
            return
        }
    }
    
    func setNotificationEveryFridayMorning() {
        let content = UNMutableNotificationContent()
        content.title = "Rappel"
        content.body = "Pensez à vérifier que vos plantes n'ont besoin de rien en ce moment ! 🌱"
        content.sound = UNNotificationSound.default
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.weekday = 6
        dateComponents.hour = 11
        dateComponents.minute = 30
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents, repeats: false)
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content, trigger: trigger)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if error != nil {
                print("ERROR ON SET NOTIFICATION")
            }
        }
    }
    
    
    func scheduleNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Success")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        setNotificationEveryWednesdayMorning()
        setNotificationEveryFridayMorning()
    }
}
