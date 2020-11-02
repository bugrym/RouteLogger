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
    private var isStarted:Bool = false
    private var isAccessAllowed:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        self.checkLocationServices()
        self.setStyles()
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(checkServices), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let rightItem = UIBarButtonItem(image: UIImage(named: "history"), style: .plain, target: self, action: #selector(historyTapped(_:)))
        let leftItem = UIBarButtonItem(image: UIImage(named: "user"), style: .plain, target: self, action: nil)
        navigationItem.rightBarButtonItem = rightItem
        navigationItem.leftBarButtonItem = leftItem
        navigationItem.backButtonTitle = ""
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
            self.controlButton.isEnabled = false
            self.present(AlertFactory.locationRestrictedAlert(), animated: true, completion: nil)
        case .authorizedAlways:
            self.controlButton.isEnabled = true
            self.mapView.showsUserLocation = true
            self.zoomToUserLocation()
            break
        case .authorizedWhenInUse:
            self.controlButton.isEnabled = true
            self.mapView.showsUserLocation = true
            self.zoomToUserLocation()
        case .notDetermined:
            self.controlButton.isEnabled = true
            LocationDriver.shared.requestWhenInUseAuthorization()
            self.mapView.showsUserLocation = true
            self.zoomToUserLocation()
        case .restricted:
            self.controlButton.isEnabled = false
            self.present(AlertFactory.locationRestrictedAlert(), animated: true, completion: nil)
        }
    }
    
    @IBAction private func centerTapped() {
        self.zoomToUserLocation()
    }
    
    @IBAction private func startTapped() {
        self.isStarted = !isStarted
        if isStarted {
            self.controlButton.setTitle("Stop", for: .normal)
            LocationDriver.shared.startJourney()
        } else {
            self.controlButton.setTitle("Start", for: .normal)
            LocationDriver.shared.stopJourney()
        }
        //        guard let currentLocation = LocationDriver.shared.getCurrentLocation() else { return }
        //        var coordinate = CLLocationCoordinate2D(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        //        let geodesic = MKGeodesicPolyline(coordinates: &coordinate, count: 1)
        //        self.mapView.addOverlay(geodesic)
        
        //        let point1 = CLLocationCoordinate2D(latitude: 46.471469504801995, longitude: 30.731533337413083)
        //        let point2 = CLLocationCoordinate2D(latitude: 46.471569504802000, longitude: 30.731533337413086)
        //        let point3 = CLLocationCoordinate2D(latitude: 46.471669504802005, longitude: 30.731533337413089)
        //        let point4 = CLLocationCoordinate2D(latitude: 46.471769504802010, longitude: 30.731533337413092)
        //        let point5 = CLLocationCoordinate2D(latitude: 46.471869504802015, longitude: 30.731533337413095)
        //
        //        let points: [CLLocationCoordinate2D]
        //        points = [point1, point2, point3, point4, point5]
        //
        //        let polyline = MKPolyline(coordinates: points, count: points.count)
        //        self.mapView.addOverlay(polyline)
    }
    
    @objc private func historyTapped(_ sender:UIBarButtonItem) {
        self.performSegue(withIdentifier: SegueIdentifier.MapViewScreen.routeHistory.rawValue, sender: self)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRender = MKPolylineRenderer(overlay: overlay)
            polylineRender.strokeColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
            polylineRender.lineWidth = 3.0
            return polylineRender
        } else {
            return MKOverlayRenderer()
        }
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

extension MapViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
