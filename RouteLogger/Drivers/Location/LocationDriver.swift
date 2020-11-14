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
    
    private var locationModel:LocationModel?
    
    func requestWhenInUseAuthorization() {
        LocationDriver.shared.manager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() -> Location? {
        LocationDriver.shared.manager.requestLocation()
        
        guard let latitude = LocationDriver.shared.latitude,
              let longitude = LocationDriver.shared.longitude else { return nil }
        
        return Location(latitude: latitude, longitude: longitude)
    }
    
    //Log user route every N seconds
    func startJourney() {
        self.locationModel = LocationModel()
        self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(saveLocation), userInfo: nil, repeats: true)
    }
    
    /**
     Method stops route logging session and save route object into Realm DB
     */
    func stopJourney() {
        self.timer?.invalidate()
        self.timer = nil
        
        //Saving Realm object
        let realm = try! Realm()
        try! realm.write { [weak self] in
            guard let strSelf = self,
                  let model = strSelf.locationModel else { return }
            realm.add(model)
        }
        self.locations = []
    }
    
    @objc private func saveLocation() {
        guard let location = LocationDriver.shared.getCurrentLocation() else { return }
        self.locations.append(location)
        self.saveObjectWith(location: location)
    }
    
    /**
     Method appends new values to the current route object
     - location: represents route location
     */
    private func saveObjectWith(location:Location) {
        let realm = try! Realm()
        try! realm.write { [weak self] in
            guard let strSelf = self else { return }
            strSelf.locationModel?.latitudes.append(location.latitude)
            strSelf.locationModel?.longitudes.append(location.longitude)
            strSelf.locationModel?.dates.append(Date())
        }
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
