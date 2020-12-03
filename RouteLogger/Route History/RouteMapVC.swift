//
//  RouteMapVC.swift
//  RouteLogger
//
//  Created by Vladyslav Bugrym on 07.11.2020.
//  Quality Assurance by Kateryna Galushka
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
        DispatchQueue.main.async { [weak self] in
            guard let strSelf = self,
                  let startPoint = strSelf.routeCoordinates.first,
                  let endPoint = strSelf.routeCoordinates.last else { return }
            strSelf.mapView.addOverlay(strSelf.polyline)
            strSelf.zoomToStartPoint()
            
            if strSelf.routeCoordinates.first != nil {
                let startCircle = MKCircle(center: startPoint, radius: 1)
                let endCircle = MKCircle(center: endPoint, radius: 1)
                strSelf.mapView.addOverlays([startCircle, endCircle])
            }
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
}

