//
//  PushNotification.swift
//  plantR_ios
//
//  Created by Boris Roussel on 22/10/2020.
//  Copyright © 2020 Agrove. All rights reserved.
//

import UIKit

struct PushTask {
    var title: String
    var body: String
    var userId: String
    var plantUID: String
    var gardenerId: String
    var stage: String
    var taskName: String
    var taskId: String
}

class PushNotificationSender {
    
    func sendPushNotification(to topics: String, title: String, body: String, userId: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : "/topics/\(topics)",
                                           "priority": "high",
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["userId" : userId, "title": title, "body": body]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(GlobalConsts.FirebaseKeyMessage)", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
    
    func sendPushTaskNotification(to topics: String, pushTask: PushTask, completion: @escaping () -> Void) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : "/topics/\(topics)",
                                           "notification" : ["title" : pushTask.title, "body" : pushTask.body],
                                           "priority": "high",
                                           "data" : [
                                            "userId" : pushTask.userId,
                                            "title": pushTask.title,
                                            "body": pushTask.body,
                                            "type": "taskDone",
                                            "plantUID": pushTask.plantUID,
                                            "stage": pushTask.stage,
                                            "gardenerId": pushTask.gardenerId,
                                            "taskName": pushTask.taskName,
                                            "taskId": pushTask.taskId
                                           ]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(GlobalConsts.FirebaseKeyMessage)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            completion()
        }).resume()
    }
}
