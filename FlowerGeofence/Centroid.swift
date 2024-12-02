//
//  Centroid.swift
//  FlowerGeofence
//
//  Created by Dinesh Kumar A on 20/11/24.
//

import Foundation
import CoreLocation

struct LocationCoordinate {
    let latitude: Double
    let longitude: Double
}

func euclideanDistance(_ a: LocationCoordinate, _ b: LocationCoordinate) -> Double {
    let latDiff = a.latitude - b.latitude
    let lonDiff = a.longitude - b.longitude
    return sqrt(latDiff * latDiff + lonDiff * lonDiff)
}

func kMeansCentroid(points: [LocationCoordinate], k: Int = 1, maxIterations: Int = 100) -> LocationCoordinate? {
    guard !points.isEmpty else { return nil }
    guard k == 1 else {
        fatalError("This implementation is designed for a single cluster (k=1).")
    }

    // Initialize centroid randomly
    var centroid = points.randomElement()!

    for _ in 0..<maxIterations {
        // Assign points to the centroid (all points belong to one cluster for k = 1)
        let cluster = points

        // Calculate the new centroid
        let newLatitude = cluster.map { $0.latitude }.reduce(0, +) / Double(cluster.count)
        let newLongitude = cluster.map { $0.longitude }.reduce(0, +) / Double(cluster.count)
        let newCentroid = LocationCoordinate(latitude: newLatitude, longitude: newLongitude)

        // Check for convergence
        if newCentroid.latitude == centroid.latitude && newCentroid.longitude == centroid.longitude {
            return centroid
        }

        centroid = newCentroid
    }

    return centroid
}

// Example Usage
//let points = [
//    LocationCoordinate(latitude: 12.971598, longitude: 77.594566),
//    LocationCoordinate(latitude: 12.972098, longitude: 77.595066),
//    LocationCoordinate(latitude: 12.970598, longitude: 77.593566),
//    LocationCoordinate(latitude: 12.971098, longitude: 77.594066),
//    LocationCoordinate(latitude: 12.971798, longitude: 77.594866)
//]

//if let centroid = kMeansCentroid(points: points) {
//    print("Centroid: Latitude = \(centroid.latitude), Longitude = \(centroid.longitude)")
//} else {
//    print("Could not calculate centroid.")
//}

import MapKit
import CoreLocation

class CentroidMapViewController: UIViewController {
//Centroid: (12.961093896151876, 77.70964953221184) Location 1: (12.961093865295215, 77.70964950214652) Location 2: (12.961093903866043, 77.70964953972819) Location 3: (12.961093903866043, 77.70964953972819) Location 4: (12.961093903866043, 77.70964953972819) Location 5: (12.961093903866043, 77.70964953972819)

//Centroid: (12.961093714298892, 77.70964938793624) Location 1: (12.961093733951726, 77.70964940418237) Location 2: (12.961093709385684, 77.7096493838747) Location 3: (12.961093709385684, 77.7096493838747) Location 4: (12.961093709385684, 77.7096493838747) Location 5: (12.961093709385684, 77.7096493838747)
//    True Location <+12.96109371,+77.70964938> +/- 15.59m (speed -1.00 mps / course -1.00) @ 24/11/24, 2:23:41 PM India Standard Time    
    /*
     Centroid: (12.96109391551993, 77.70964955427681) Location 1: (12.96109389864311, 77.70964954032547) Location 2: (12.961093909196062, 77.70964954904912) Location 3: (12.961093920708281, 77.70964955856577) Location 4: (12.961093920708281, 77.70964955856577) Location 5: (12.961093928343915, 77.70964956487782)
     True Location <+12.96109393,+77.70964956> +/- 15.65m (speed -1.00 mps / course -1.00) @ 24/11/24, 2:27:01 PM India Standard Time
     
     Centroid: (12.961093849413123, 77.7096494996292) Location 1: (12.961093935394343, 77.7096495707061) Location 2: (12.961093857479023, 77.70964950629694) Location 3: (12.961093857479023, 77.70964950629694) Location 4: (12.961093798356387, 77.70964945742284) Location 5: (12.961093798356849, 77.70964945742323)
     True Location <+12.96109380,+77.70964946> +/- 13.79m (speed -1.00 mps / course -1.00) @ 24/11/24, 7:10:58 PM India Standard Time
     */
    
    // MARK: - Properties
    var trueLocation = CLLocation(latitude: 12.96109380, longitude: 77.70964946)
    var locations: [CLLocation] = [CLLocation(latitude: 12.961093935394343, longitude: 77.7096495707061),
                                   CLLocation(latitude: 12.961093857479023, longitude: 77.70964950629694),
                                   CLLocation(latitude: 12.961093857479023, longitude: 77.70964950629694),
                                   CLLocation(latitude: 12.961093798356387, longitude: 77.70964945742284),
                                   CLLocation(latitude: 12.961093798356849, longitude: 77.70964945742323)] // Array to store the 5 locations
    var mapView: MKMapView!

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        addAnnotations()
    }

    // MARK: - Setup MapView
    private func setupMapView() {
        mapView = MKMapView(frame: view.bounds)
        mapView.delegate = self
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
    }

    // MARK: - Add Annotations
    private func addAnnotations() {
        guard !locations.isEmpty else { return }
        
        // Add numbered pins for the 5 locations
                for (index, location) in locations.enumerated() {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = location.coordinate
                    print("Add", index + 1)
                    annotation.title = "Point \(index + 1), HA: \(location.horizontalAccuracy)"
                    mapView.addAnnotation(annotation)
                }
                
                // Calculate and add the centroid pin
                if let centroidCoordinate = calculateCentroid(for: locations) {
                    let centroidAnnotation = MKPointAnnotation()
                    centroidAnnotation.coordinate = centroidCoordinate
                    centroidAnnotation.title = "Centroid"
                    mapView.addAnnotation(centroidAnnotation)
                    
                    let region = MKCoordinateRegion(
                        center: centroidCoordinate,
                        latitudinalMeters: 1000, // 500 meters in all directions
                        longitudinalMeters: 1000
                    )
                    
                    // Set the region
                    mapView.setRegion(region, animated: true)
                }else {
                    print("No centroid")
                }

        // Adjust the map region to show all annotations
//        mapView.showAnnotations(mapView.annotations, animated: true)
        // Adjust the map region to show all annotations
        // Define a 500-meter radius
            
    }
    
    private func setMapRegion() {
        guard !locations.isEmpty else { return }
        
        // Get all the coordinates
        var coordinates = locations.map { $0.coordinate }
        
        // Include the centroid coordinate
        if let centroidCoordinate = calculateCentroid(for: locations) {
            coordinates.append(centroidCoordinate)
        }
        
        // Calculate the bounding region
        var minLat = coordinates.map { $0.latitude }.min() ?? 0.0
        var maxLat = coordinates.map { $0.latitude }.max() ?? 0.0
        var minLon = coordinates.map { $0.longitude }.min() ?? 0.0
        var maxLon = coordinates.map { $0.longitude }.max() ?? 0.0
        
        // Add a small padding to the region
        let latPadding = 0.005  // Adjust for tighter zoom
        let lonPadding = 0.005
        minLat -= latPadding
        maxLat += latPadding
        minLon -= lonPadding
        maxLon += lonPadding
        
        // Create a region from the bounds
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: maxLat - minLat,
            longitudeDelta: maxLon - minLon
        )
        
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }

    
    func getMeansCentroid(points: [CLLocation], k: Int = 1, maxIterations: Int = 100) -> CLLocation? {
        guard !points.isEmpty else { return nil }
        guard k == 1 else {
            fatalError("This implementation is designed for a single cluster (k=1).")
        }

        // Initialize centroid randomly
        var centroid = points.randomElement()!

        for _ in 0..<maxIterations {
            // Assign points to the centroid (all points belong to one cluster for k = 1)
            let cluster = points

            // Calculate the new centroid
            let newLatitude = cluster.map { $0.coordinate.latitude }.reduce(0, +) / Double(cluster.count)
            let newLongitude = cluster.map { $0.coordinate.longitude }.reduce(0, +) / Double(cluster.count)
            let newCentroid = CLLocation(latitude: newLatitude, longitude: newLongitude)

            // Check for convergence
            if newCentroid.coordinate.latitude == centroid.coordinate.latitude && newCentroid.coordinate.longitude == centroid.coordinate.longitude {
                return centroid
            }

            centroid = newCentroid
        }

        return centroid
    }

    // MARK: - Calculate Centroid
    private func calculateCentroid(for locations: [CLLocation]) -> CLLocationCoordinate2D? {
        let centroid = getMeansCentroid(points: locations)
        return centroid?.coordinate
//        guard !locations.isEmpty else { return nil }
//        
//        let totalLatitude = locations.map { $0.coordinate.latitude }.reduce(0, +)
//        let totalLongitude = locations.map { $0.coordinate.longitude }.reduce(0, +)
//        
//        let centroidLatitude = totalLatitude / Double(locations.count)
//        let centroidLongitude = totalLongitude / Double(locations.count)
//        
//        return CLLocationCoordinate2D(latitude: centroidLatitude, longitude: centroidLongitude)
    }
}

// MARK: - MapView Delegate for Custom Pin Colors
extension CentroidMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier: String
            var annotationView: MKPinAnnotationView?
            
            if annotation.title == "Centroid" {
                identifier = "CentroidPin"
            } else {
                identifier = "NumberedPin"
            }
            
            // Reuse or create annotation view
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                annotationView?.animatesDrop = true
            } else {
                annotationView?.annotation = annotation
            }

            // Customize pin appearance
            if identifier == "CentroidPin" {
                annotationView?.pinTintColor = .red // Centroid pin color
            } else {
                annotationView?.pinTintColor = .blue // Numbered pins color
            }

            return annotationView
        }
}
