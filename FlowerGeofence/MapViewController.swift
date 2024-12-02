//
//  MapViewController.swift
//  FlowerGeofence
//
//  Created by Dinesh Kumar A on 20/10/24.
//

import UIKit
import MapKit
import CoreLocation


// MKMapViewDelegate Methods
extension MapViewController: MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circleOverlay = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circleOverlay)
                renderer.strokeColor = UIColor.red
                renderer.lineWidth = 2.0
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    
//    // Custom MKAnnotationView for showing accuracy
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard let annotation = annotation as? LocationAnnotation else { return nil }
//
//        let identifier = "LocationAnnotationView"
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//
//        if annotationView == nil {
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//            annotationView?.canShowCallout = true
//            
//            // Create a custom label to display the accuracy
//            let accuracyLabel = UILabel()
//            accuracyLabel.text = "Accuracy: \(annotation.accuracy) m"
//            accuracyLabel.font = UIFont.systemFont(ofSize: 12)
//            accuracyLabel.textColor = .white
//            accuracyLabel.backgroundColor = .red
//            accuracyLabel.textAlignment = .center
//            accuracyLabel.frame = CGRect(x: 0, y: 0, width: 120, height: 30)
//            annotationView?.detailCalloutAccessoryView = accuracyLabel
//            
//            // Customizing the pin (color and size)
//            annotationView?.image = UIImage(named: "RedPin") // Custom pin if needed
//        }
//
//        return annotationView
//    }
    
}


protocol MapViewControllerDelegate: AnyObject {
    func didUpdateLocation(_ location: CLLocation)
    func didEnterGeofence(identifier: String, at location: CLLocation)
    func didExitGeofence(identifier: String, at location: CLLocation)
}

class MapViewController: UIViewController {
    private let mapView = MKMapView()
    
    var lastKnownLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()

        // Listen for location updates
        NotificationCenter.default.addObserver(self, selector: #selector(handleLocationUpdate(_:)), name: .locationUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleGeofenceEntered(_:)), name: Notification.Name("GeofenceEntered"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleGeofenceExited(_:)), name: Notification.Name("GeofenceExited"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleGeofenceCreated(_:)), name: Notification.Name("CreatedGeofence"), object: nil)
        
        if let location = lastKnownLocation {
            updateLocationOnMap(location: location)
            drawGeofences(at: location)
        }
    }
    
    

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupMapView() {
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        mapView.showsUserLocation = true
    }
    
    @objc private func handleLocationUpdate(_ notification: Notification) {
        if let location = notification.object as? CLLocation {
            updateLocationOnMap(location: location)
        }
    }
    
    @objc private func handleGeofenceEntered(_ notification: Notification) {
        if let (identifier, location) = notification.object as? (String, CLLocation) {
            addGeofenceAtLocation(location, identifier: identifier)
        }
    }
    
    @objc private func handleGeofenceExited(_ notification: Notification) {
        if let (identifier, location) = notification.object as? (String, CLLocation) {
            // Handle geofence exit if needed
            addGeofenceAtLocation(location, identifier: identifier) // or handle differently
        }
    }
    
    @objc private func handleGeofenceCreated(_ notification: Notification) {
        if let (identifier, location) = notification.object as? (String, CLLocation) {
           drawGeofences(at: location)
        }
    }


    
    func updateLocationOnMap(location: CLLocation) {
        // Set the desired zoom level
        let regionRadius: CLLocationDistance = 200
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)

        // Clear existing annotations
//        mapView.removeAnnotations(mapView.annotations)
        
        // Add the new location as an annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = "Current Location"
        annotation.subtitle = "Accuracy: \(location.horizontalAccuracy) meters"
        mapView.addAnnotation(annotation)

        // Animate the transition to the new location **after adding the annotation**
        mapView.setRegion(region, animated: true)
    }

    
    func addGeofenceAtLocation(_ location: CLLocation, identifier: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = identifier
        annotation.subtitle = "Accuracy: \(location.horizontalAccuracy) meters"
        mapView.addAnnotation(annotation)
        
        

        // Set the desired zoom level
        let regionRadius: CLLocationDistance = 200
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)

        // Zoom the map to the new location
        mapView.setRegion(region, animated: true)
    }

    private func drawGeofences(at location: CLLocation) {
        let defaults = UserDefaults.standard
        
        

        let innerRadius: CLLocationDistance = defaults.double(forKey: "innerRadius")
        let petalOffset = innerRadius * GeofenceConstants.petalOffset     // Offset for petals from the inner geofence (50% of innerRadius)
        let petalRadius = innerRadius * GeofenceConstants.petalRadius        // Radius of each petal geofence (30% of innerRadius)
        let outerOffset = innerRadius * GeofenceConstants.outerOffset        // Offset for outer geofence from the petals (20% of innerRadius)
        let outerRadius = innerRadius + petalOffset + petalRadius + outerOffset
        
        
//        let petalOffset: CLLocationDistance = defaults.double(forKey: "petalOffset")//innerRadius - 10 // Offset for petals from the inner geofence
//        let outerOffset: CLLocationDistance = 10 // Offset for outer geofence from the petals
//        let petalRadius: CLLocationDistance = defaults.double(forKey: "petalRadius") // Radius of each petal geofence
        let numberOfPetals = 6//Int(max(4, min(12, innerRadius / 10)))
        // Clear previous geofence overlays
        mapView.removeOverlays(mapView.overlays)

        // Draw Inner Geofence
        let innerCircle = MKCircle(center: location.coordinate, radius: innerRadius)
        mapView.addOverlay(innerCircle)

        // Draw Petal Geofences
        let angleStep = 360.0 / Double(numberOfPetals)
        for i in 0..<numberOfPetals {
              let angle = angleStep * Double(i) * .pi / 180.0
              // Add the petalOffset to the innerRadius to calculate the distance from the center
            let petalCenter = calculatePetalCenter(from: location.coordinate, radius: innerRadius + petalOffset, angle: angle)
            let petalCircle = MKCircle(center: petalCenter, radius: petalRadius)
            mapView.addOverlay(petalCircle)
          }


        // Draw Outer Geofence
//        let outerGeofenceRadius = innerRadius + petalOffset + petalRadius + outerOffset
        let outerCircle = MKCircle(center: location.coordinate, radius: outerRadius)
        mapView.addOverlay(outerCircle)

        // Set the region to encompass all geofences with controlled zoom
//        let padding: CGFloat = 150.0
//        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: outerGeofenceRadius * 2 + padding, longitudinalMeters: outerGeofenceRadius * 2 + padding)
//        mapView.setRegion(region, animated: true)
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 150, longitudinalMeters: 150)
        mapView.setRegion(region, animated: true)
    }
    
    // Helper method to calculate petal center coordinates
    // Calculate the center for each petal geofence based on angle and radius
    private func calculatePetalCenter(from center: CLLocationCoordinate2D, radius: CLLocationDistance, angle: Double) -> CLLocationCoordinate2D {
        let earthRadius: CLLocationDistance = 6371000 // Earth's radius in meters
        let latitudeOffset = radius / earthRadius * cos(angle)
        let longitudeOffset = radius / (earthRadius * cos(center.latitude * .pi / 180)) * sin(angle)

        let latitude = center.latitude + (latitudeOffset * 180.0 / .pi)
        let longitude = center.longitude + (longitudeOffset * 180.0 / .pi)

        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    
    
    
}


//// Create a custom annotation
//class LocationAnnotation: MKPointAnnotation {
//    var accuracy: CLLocationDistance
//    init(coordinate: CLLocationCoordinate2D, accuracy: CLLocationDistance) {
//        self.accuracy = accuracy
//        super.init()
//        self.coordinate = coordinate
//    }
//}
