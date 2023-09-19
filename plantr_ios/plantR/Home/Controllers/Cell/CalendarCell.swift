//
//  CalendarCell.swift
//  plantR_ios
//
//  Created by Rabissoni on 14/03/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarCell: JTAppleCell {
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet weak var selectedDate: CornerRaduisV!
    @IBOutlet var todayDayView: CIRoundedImageView!
    @IBOutlet var taskDayView: CIRoundedImageView!
    @IBOutlet weak var taskDayWhiteView: CIRoundedImageView!
    
}
