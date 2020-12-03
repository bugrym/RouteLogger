//
//  MapViewController.swift
//  RouteLogger
//
//  Created by Vladyslav Bugrym on 02.10.2020.
//  Quality Assurance by Kateryna Galushka
//

import UIKit
import MapKit
import CoreLocation

final class MapViewController: UIViewController, MKMapViewDelegate {
    
    enum State {
        case active, inactive
    }
    
    @IBOutlet private weak var mapView:MKMapView!
    @IBOutlet private weak var controlButton:UIButton!
    @IBOutlet private weak var centerButton:UIButton!
    
    private lazy var routeCoordinates:[CLLocationCoordinate2D] = []
    private var polyline:MKPolyline {
        let polyline = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
        return polyline
    }
    
    private var state:State = .inactive
    private var isStarted:Bool = false
    private var isAccessAllowed:Bool = false
    private var timer:Timer?
    
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
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: userLocation.latitude, longitude:  userLocation.longitude), latitudinalMeters: 300, longitudinalMeters: 300)
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
            break
        case .authorizedWhenInUse:
            self.controlButton.isEnabled = true
            self.mapView.showsUserLocation = true
        case .notDetermined:
            self.controlButton.isEnabled = true
            LocationDriver.shared.requestWhenInUseAuthorization()
            self.mapView.showsUserLocation = true
        case .restricted:
            self.controlButton.isEnabled = false
            self.present(AlertFactory.locationRestrictedAlert(), animated: true, completion: nil)
        @unknown default:
            fatalError()
        }
    }
    
    @IBAction private func centerTapped() {
        self.zoomToUserLocation()
    }
    
    @IBAction private func startTapped() {
        DispatchQueue.main.async { [weak self] in
            guard let strSelf = self else { return }
            strSelf.isStarted = !strSelf.isStarted
            if strSelf.isStarted {
                strSelf.controlButton.setTitle("Stop", for: .normal)
                strSelf.controlButton.isEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + LocationDriver.shared.locationRequestTimeInterval) {
                    strSelf.controlButton.isEnabled = true
                }
                
                LocationDriver.shared.startJourney()
                strSelf.timer = Timer.scheduledTimer(timeInterval: LocationDriver.shared.locationRequestTimeInterval, target: strSelf, selector: #selector(strSelf.drawRoute), userInfo: nil, repeats: true)
            } else {
                strSelf.present(AlertFactory.routeSavingAlert(), animated: true, completion: nil)
                strSelf.controlButton.setTitle("Start", for: .normal)
                LocationDriver.shared.stopJourney()
                strSelf.timer?.invalidate()
                strSelf.timer = nil
                strSelf.routeCoordinates = []
                DispatchQueue.main.async {
                    strSelf.mapView.removeOverlays(strSelf.mapView.overlays)
                }
            }
        }
    }
    
    @objc private func drawRoute() {
        guard let currentLocation = LocationDriver.shared.getCurrentLocation() else { return }
        let latestCoordinate = CLLocationCoordinate2D(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        
        //        //TODO: - Fix bend route
        //        guard let previousCoordinate = self.routeCoordinates.last else { return }
        //        let previousPoint = CLLocation(latitude: previousCoordinate.latitude, longitude: previousCoordinate.longitude)
        //        let latestPoint = CLLocation(latitude: latestCoordinate.latitude, longitude: latestCoordinate.longitude)
        //        let distance = latestPoint.distance(from: previousPoint)
        //
        //        if distance >= (previousPoint.horizontalAccuracy * 0.5) {
        //            self.routeCoordinates.append(latestCoordinate)
        //        }
        
        self.routeCoordinates.append(latestCoordinate)
        
        DispatchQueue.main.async { [weak self] in
            guard let strSelf = self,
                  let center = strSelf.routeCoordinates.first else { return }
            strSelf.mapView.addOverlay(strSelf.polyline)
            
            if strSelf.routeCoordinates.first != nil {
                let circle = MKCircle(center: center, radius: 1)
                strSelf.mapView.addOverlay(circle)
            }
        }
    }
    
    @objc private func historyTapped(_ sender:UIBarButtonItem) {
        self.performSegue(withIdentifier: SegueIdentifier.MapViewScreen.routeHistory.rawValue, sender: self)
    }
    
    @IBAction private func toggleStepper(_ sender:UIStepper) {
        LocationDriver.shared.locationRequestTimeInterval = sender.value
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRender = MKPolylineRenderer(overlay: overlay)
            polylineRender.strokeColor = #colorLiteral(red: 0.3307623863, green: 0.8076304793, blue: 0.3619797826, alpha: 1)
            polylineRender.lineWidth = 7.0
            return polylineRender
        } else if overlay is MKCircle {
            let circleRender = MKCircleRenderer(overlay: overlay)
            circleRender.strokeColor = .red
            circleRender.lineWidth = 10.0
            circleRender.fillColor = .red
            return circleRender
        } else {
            return MKOverlayRenderer()
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
    }
    //
    //    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    //        self.state = .active
    //    }
}

extension MapViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
