//
//  Location.swift
//  RouteLogger
//
//  Created by Vladyslav Bugrym on 02.10.2020.
//

import Foundation

struct Location {
    let latitude:Double
    let longitude:Double
    let routeStartTime:Date
    
    init(latitude:Double, longitude:Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.routeStartTime = Date.init()
    }
}
