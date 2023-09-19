//
//  Irrigation.swift
//  plantR_ios
//
//  Created by Adison Pereira de oliveira on 18/05/2022.
//  Copyright © 2022 Agrove. All rights reserved.
//

import Foundation

struct Irrigation {
    let payload: String
    let received: ReceivedIrrg
}

struct ReceivedIrrg {
    let request: RequestIrrig
    let status: String
    let updated: String
}

struct RequestIrrig {
    let value: ValueIrrig
}

struct ValueIrrig {
    let data: String
}
