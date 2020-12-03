//
//  LocationModel.swift
//  RouteLogger
//
//  Created by Vladyslav Bugrym on 02.10.2020.
//  Quality Assurance by Kateryna Galushka
//

import Foundation
import RealmSwift

class LocationModel:Object {
    let latitudes = List<Double>()
    let longitudes = List<Double>()
    let dates = List<Date>()
    @objc dynamic var isFavorite:Bool = false
}
