//
//  ActivityStatus.swift
//  PedometerHelper
//
//  Created by Siamak Rostami on 8/9/21.
//

import Foundation

enum CurrentActivityStatus : String {
    case
        stationary = "stationary" ,
        automotive = "automotive",
        running = "running" ,
        cycling = "cycling",
        walking = "walking",
        unknown = "unknown"
}
