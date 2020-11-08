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
    
    private lazy var routeCoordinates:[CLLocationCoordinate2D] = []
    private var polyline:MKPolyline {
        let polyline = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
        return polyline
    }
    
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
        DispatchQueue.main.async { [weak self] in
            guard let strSelf = self else { return }
            strSelf.isStarted = !strSelf.isStarted
            if strSelf.isStarted {
                strSelf.controlButton.setTitle("Stop", for: .normal)
                LocationDriver.shared.startJourney()
                strSelf.timer = Timer.scheduledTimer(timeInterval: 3, target: strSelf, selector: #selector(strSelf.drawRoute), userInfo: nil, repeats: true)
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
        let coordinate = CLLocationCoordinate2D(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        self.routeCoordinates.append(coordinate)
        DispatchQueue.main.async { [weak self] in
            guard let strSelf = self else { return }
            strSelf.mapView.addOverlay(strSelf.polyline)
        }
    }
    
    @objc private func historyTapped(_ sender:UIBarButtonItem) {
        self.performSegue(withIdentifier: SegueIdentifier.MapViewScreen.routeHistory.rawValue, sender: self)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRender = MKPolylineRenderer(overlay: overlay)
            polylineRender.strokeColor = #colorLiteral(red: 0.3307623863, green: 0.8076304793, blue: 0.3619797826, alpha: 1)
            polylineRender.lineWidth = 5.0
            return polylineRender
        } else {
            return MKOverlayRenderer()
        }
    }
}

extension MapViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
