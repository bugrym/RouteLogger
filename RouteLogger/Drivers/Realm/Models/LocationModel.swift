//
//  LocationModel.swift
//  RouteLogger
//
//  Created by Vladyslav Bugrym on 02.10.2020.
//

import Foundation
import RealmSwift

class LocationModel:Object {
    @objc dynamic var latitude:Double = 0.0
    @objc dynamic var longitude:Double = 0.0
    @objc dynamic var date:Date?
}
