//
//  RouteMapVC.swift
//  RouteLogger
//
//  Created by Vladyslav Bugrym on 07.11.2020.
//

import UIKit
import MapKit
import CoreLocation

final class RouteMapVC: UIViewController, MKMapViewDelegate {
    
    @IBOutlet private weak var mapView:MKMapView!
    
    public var locationModel:LocationModel?
    private lazy var routeCoordinates:[CLLocationCoordinate2D] = []
    private var polyline:MKPolyline {
        let polyline = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
        return polyline
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        self.getPoints()
        self.drawRoute()
    }
    
    private func drawRoute() {
        DispatchQueue.main.async {
            self.mapView.addOverlay(self.polyline)
            self.zoomToStartPoint()
        }
    }
    
    private func getPoints() {
        guard let model = self.locationModel else { return }
        
        for point in 0..<model.latitudes.count {
            let point = CLLocationCoordinate2D(latitude: model.latitudes[point], longitude: model.longitudes[point])
            self.routeCoordinates.append(point)
        }
    }
    
    private func zoomToStartPoint() {
        guard let center = self.routeCoordinates.first else { return }
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 300, longitudinalMeters: 300)
        self.mapView.setRegion(region, animated: true)
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

