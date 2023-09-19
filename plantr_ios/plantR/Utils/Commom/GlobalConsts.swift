//
//  GlobalConsts.swift
//  plantR_ios
//
//  Created by Rabissoni on 17/01/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit

enum GlobalConsts {

    #if DEBUG
    static let ChannelTopics = "ChannelTopics"
    static let FirebaseKeyMessage = "AAAAd_Geoag:APA91bEt_T6-Fg738UJRRLJOUiPd4AxToBuEuu4YDLXsa3RGiivLS5nyO7_ruDb08EJF2RWCHKKoFiAlia9yaJcTBuVoVUYOl1ouG4HAMj9t_AXOYpGXPTbWqxsj0vFm4JuS0fA80Gkt"
    static let EnvironmentPrefix = "test_"
    #else
    static let FirebaseKeyMessage = "AAAAd_Geoag:APA91bEt_T6-Fg738UJRRLJOUiPd4AxToBuEuu4YDLXsa3RGiivLS5nyO7_ruDb08EJF2RWCHKKoFiAlia9yaJcTBuVoVUYOl1ouG4HAMj9t_AXOYpGXPTbWqxsj0vFm4JuS0fA80Gkt"
    static let ChannelTopics = "ChannelTopics"
    static let EnvironmentPrefix = ""
    #endif
}

enum Styles {

    static let PlantRMainGreen = UIColor(red: 0.41, green: 0.87, blue: 0.64, alpha: 1)
    static let PlantRLightGrey = #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
    static let PlantRDefaultBackground = #colorLiteral(red: 0.9529411765, green: 0.9568627451, blue: 0.9490196078, alpha: 1)
    static let PlantRBlackColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    static let PlantRDarkGrey = #colorLiteral(red: 0.2117647059, green: 0.7803921569, blue: 0.6588235294, alpha: 1)
    static let PlantRGreenProgressBarFriend = #colorLiteral(red: 0.4078431373, green: 0.8666666667, blue: 0.6431372549, alpha: 1)
    static let PlantRDarkGreenProgressBar = #colorLiteral(red: 0.4401134253, green: 0.7800175548, blue: 0.5805541277, alpha: 1)
    static let PlantRGreenBarFriend = #colorLiteral(red: 0.4078431373, green: 0.8666666667, blue: 0.6431372549, alpha: 0.3)
    static let PlantRRedProgressBarFriend = #colorLiteral(red: 0.8156862745, green: 0.007843137255, blue: 0.1058823529, alpha: 1)
    static let PlantROrangeProgressBarFriend = #colorLiteral(red: 0.9607843137, green: 0.6509803922, blue: 0.137254902, alpha: 1)
    static let PlantRRedTasksCalendar = #colorLiteral(red: 1, green: 0.1529411765, blue: 0.09019607843, alpha: 1)
    static let PlantRGreenTasksCalendar = #colorLiteral(red: 0.1071263775, green: 0.8870967031, blue: 0.6510254145, alpha: 1)
    static let PlantRTabColor = #colorLiteral(red: 0.7584043145, green: 0.9479627013, blue: 0.8528500795, alpha: 1)
}

enum Rank: Int {

    case beginner = 0
    case intermediate = 1
    case advance = 2
    case expert = 3

    func getTitle() -> String {

        switch self {
        case .beginner:
            return "Débutant"
        case .intermediate:
            return "Intermédiaire"
        case .advance:
            return "Avancé"
        default:
            return "Expert"
        }
    }
}

enum ErrorPairing {
    
    static let Bluetooth = "BLE ERROR"
    static let Wifi = "WIFI ERROR"
}
