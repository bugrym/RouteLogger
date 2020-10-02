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
    
    @IBOutlet private var mapView:MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationDriver.shared.requestPermission()
        self.getCurrentLocation()
    }
    
    private func getCurrentLocation() {
        print(LocationDriver.shared.getCurrentLocation())
    }
    
    
}

