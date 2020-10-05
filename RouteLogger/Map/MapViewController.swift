//
//  MapViewController.swift
//  RouteLogger
//
//  Created by Vladyslav Bugrym on 02.10.2020.
//

import UIKit
import MapKit
import CoreLocation

final class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet private weak var mapView:MKMapView!
    @IBOutlet private weak var controlButton:UIButton!
    @IBOutlet private weak var centerButton:UIButton!
    
    private lazy var routeCoordinates:[Location] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkLocationServices()
        self.setStyles()
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(checkServices), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func setStyles() {
        self.controlButton.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        self.controlButton.layer.cornerRadius = self.controlButton.frame.size.height / 2
    }
    
    private func zoomToUserLocation() {
        guard let userLocation = LocationDriver.shared.getCurrentLocation() else { return }
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: userLocation.latitude, longitude:  userLocation.longitude), latitudinalMeters: 200, longitudinalMeters: 200)
        self.mapView.setRegion(region, animated: true)
    }
    
    @objc private func checkServices() {
        self.checkLocationServices()
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            self.checkLocationAuthorization()
        } else {
            self.present(AlertFactory.locationRestrictedAlert(), animated: true, completion: nil)
        }
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .denied:
            self.present(AlertFactory.locationRestrictedAlert(), animated: true, completion: nil)
        case .authorizedAlways:
            self.mapView.showsUserLocation = true
            self.zoomToUserLocation()
            break
        case .authorizedWhenInUse:
            self.mapView.showsUserLocation = true
            self.zoomToUserLocation()
        case .notDetermined:
            LocationDriver.shared.requestWhenInUseAuthorization()
            self.mapView.showsUserLocation = true
            self.zoomToUserLocation()
        case .restricted:
            self.present(AlertFactory.locationRestrictedAlert(), animated: true, completion: nil)
        }
    }
    
    @IBAction private func centerTapped() {
        self.zoomToUserLocation()
    }
    
    @IBAction private func startTapped() {
//        guard let currentLocation = LocationDriver.shared.getCurrentLocation() else { return }
//        var coordinate = CLLocationCoordinate2D(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
//        let geodesic = MKGeodesicPolyline(coordinates: &coordinate, count: 1)
//        self.mapView.addOverlay(geodesic)
        
        let point1 = CLLocationCoordinate2DMake(-73.761105, 41.017791)
            let point2 = CLLocationCoordinate2DMake(-73.760701, 41.019348)
            let point3 = CLLocationCoordinate2DMake(-73.757201, 41.019267)
            let point4 = CLLocationCoordinate2DMake(-73.757482, 41.016375)
            let point5 = CLLocationCoordinate2DMake(-73.761105, 41.017791)
            
            let points: [CLLocationCoordinate2D]
            points = [point1, point2, point3, point4, point5]
            
            let geodesic = MKGeodesicPolyline(coordinates: points, count: 5)
        self.mapView.addOverlay(geodesic)
        let region = MKCoordinateRegion(center: point1, latitudinalMeters: 200, longitudinalMeters: 200)
        self.mapView.setRegion(region, animated: true)
        
    }
    
    private func drawRouteWith(latitude:Double, longitude:Double) {
        
//        self.routeCoordinates.last.map { (location) in
//            var point = MKMapPoint(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
//            var converted = convertArr(count: <#T##Int#>, data: <#T##UnsafePointer<T>#>)
//
//            let polyline = MKPolyline(points: point, count: <#T##Int#>)
//        }
//
//
//
//
//        let geodesic = MKGeodesicPolyline(coordinates: CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude), count: <#T##Int#>
        }
}
