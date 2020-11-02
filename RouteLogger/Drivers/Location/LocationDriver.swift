//
//  LocationDriver.swift
//  RouteLogger
//
//  Created by Vladyslav Bugrym on 02.10.2020.
//

import Foundation
import CoreLocation
import RealmSwift

final class LocationDriver:NSObject {
    
    static let shared:LocationDriver = LocationDriver()
    
    private var latitude:Double?
    private var longitude:Double?
    private var timer:Timer?
    private var locations:[Location] = []
    
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
    
    //Log user route every 5 seconds
    func startJourney() {
        self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(saveLocation), userInfo: nil, repeats: true)
    }
    
    func stopJourney() {
        self.timer?.invalidate()
        self.timer = nil
        
        //Creating and saving Realm object
        let realm = try! Realm()
        try! realm.write {
            let model = LocationModel()
            for location in 0..<self.locations.count {
                model.latitudes.append(locations[location].latitude)
                model.longitudes.append(locations[location].longitude)
                model.dates.append(Date())
            }
            realm.add(model)
        }
        self.locations = []
    }
    
    @objc private func saveLocation() {
        guard let location = LocationDriver.shared.getCurrentLocation() else { return }
        self.locations.append(location)
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
