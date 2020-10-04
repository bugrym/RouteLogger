//
//  LocationDriver.swift
//  RouteLogger
//
//  Created by Vladyslav Bugrym on 02.10.2020.
//

import Foundation
import CoreLocation

final class LocationDriver:NSObject {
    
    static let shared:LocationDriver = LocationDriver()
    
    private var latitude:Double?
    private var longitude:Double?
    
    private lazy var manager:CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.allowsBackgroundLocationUpdates = true
        manager.startUpdatingLocation()
        manager.desiredAccuracy = 1
        return manager
    }()
    
    func requestWhenInUseAuthorization() {
        LocationDriver.shared.manager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() -> Location? {
        LocationDriver.shared.manager.requestLocation()
        
        guard let latitude = LocationDriver.shared.latitude,
              let longitude = LocationDriver.shared.longitude else { return nil }
        
        return Location(latitude: latitude, longitude: longitude)
    }
}

extension LocationDriver:CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location request failed with error:\(error.localizedDescription)")
    }
}
