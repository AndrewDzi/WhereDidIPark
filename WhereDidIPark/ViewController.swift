//
//  ViewController.swift
//  WhereDidIPark
//
//  Created by Andrew  on 7/25/18.
//  Copyright © 2018 Andrew . All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var theMapView: MKMapView!
    @IBOutlet weak var parkOrFindMyCarOutlet: UIBarButtonItem!
    @IBOutlet weak var actionOutlet: UIBarButtonItem!
    
    let locationManager = CLLocationManager()
    let notoficationHapticGenerator = UINotificationFeedbackGenerator()
    
    
    var parkedCarCoordinate = CLLocationCoordinate2D()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cofigureMapView()
        
        
        //chech app state for action button
        if parkOrFindMyCarOutlet.title == "Park my car!" {
            actionOutlet.isEnabled = false
        } else {
            actionOutlet.isEnabled = true
        }
    }


    func cofigureMapView() {
        theMapView.delegate = self
        theMapView.showsScale = true
        theMapView.showsTraffic = true
        theMapView.showsBuildings = true
        theMapView.showsUserLocation = true
        theMapView.showsPointsOfInterest = true
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func buildRoute() {
        
    }
    
    @IBAction func parkOrFindMyCarButton(_ sender: Any) {
        if parkOrFindMyCarOutlet.title == "Park my car!" {
            parkedCarCoordinate = (locationManager.location?.coordinate)!
            print(parkedCarCoordinate)
            notoficationHapticGenerator.notificationOccurred(.success)
            parkOrFindMyCarOutlet.title = "Find my car!"
            actionOutlet.isEnabled = true
        } else if parkOrFindMyCarOutlet.title == "Find my car!" {
            
            
            let sourceCoordinate = locationManager.location?.coordinate
            let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate!)
            let destinationPlacemark = MKPlacemark(coordinate: parkedCarCoordinate)
            let sourceItem = MKMapItem(placemark: sourcePlacemark)
            let destinationItem = MKMapItem(placemark: destinationPlacemark)
            let derectionRequest = MKDirectionsRequest()
            //Derection request
            derectionRequest.source = sourceItem
            derectionRequest.destination = destinationItem
            derectionRequest.transportType = .walking
            
            let derections = MKDirections(request: derectionRequest)
            derections.calculate(completionHandler: {response, error in
                guard let response = response else {
                    if let error = error {
                        print("derections.calculate ERROR")
                    }
                    return
                }
                let route = response.routes[0]
                self.theMapView.add(route.polyline, level: .aboveRoads)
                
                let rekt = route.polyline.boundingMapRect
                self.theMapView.setRegion(MKCoordinateRegionForMapRect(rekt), animated: true)
            })
            func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
                let renderer = MKPolylineRenderer(overlay: overlay)
                renderer.strokeColor = UIColor.blue
                renderer.lineWidth = 5.0
                
                return renderer
            }
            
            parkOrFindMyCarOutlet.title = "I found my car!"
        } else {
            
            parkOrFindMyCarOutlet.title = "Park my car!"
            actionOutlet.isEnabled = false
        }
    }
    
}

