//
//  GeofenceManager.swift
//  FlowerGeofence
//
//  Created by Dinesh Kumar A on 19/10/24.
//

import Foundation
import CoreLocation

class GeofenceManager: GeofenceTracking {
    private var locationManager: CLLocationManager
    private var monitoredRegions: [CLCircularRegion] = []
    
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
    }
    
    func createFlowerGeofences(at location: CLLocationCoordinate2D, innerRadius: CLLocationDistance) {
        removeAllGeofences() // Clean existing geofences
        
        let petalOffset = innerRadius * 0.5         // Offset for petals from the inner geofence (50% of innerRadius)
        let petalRadius = innerRadius * 0.8        // Radius of each petal geofence (30% of innerRadius)
        let outerOffset = innerRadius * 0.2         // Offset for outer geofence from the petals (20% of innerRadius)
        let outerRadius = innerRadius + petalOffset + petalRadius + outerOffset
        
        // Inner geofence
        let innerGeofence = CLCircularRegion(center: location, radius: innerRadius, identifier: "InnerGeofence")
        locationManager.startMonitoring(for: innerGeofence)
        monitoredRegions.append(innerGeofence)

        // Petal geofences
//        let petalRadius = innerRadius + 30 // Adjust for overlap
        let numberOfPetals = 8
        let angleStep = 360.0 / Double(numberOfPetals)
        
        
        for i in 0..<numberOfPetals {
            let angle = angleStep * Double(i) * .pi / 180.0
            let petalCenter = calculatePetalCenter(from: location, radius: petalRadius, angle: angle)
            let petalGeofence = CLCircularRegion(center: petalCenter, radius: petalRadius, identifier: "PetalGeofence-\(i)")
            locationManager.startMonitoring(for: petalGeofence)
            monitoredRegions.append(petalGeofence)
        }
        
        // Outer geofence
//        let outerRadius = innerRadius + 100 // Adjust for outer circle
        let outerGeofence = CLCircularRegion(center: location, radius: outerRadius, identifier: "OuterGeofence")
        locationManager.startMonitoring(for: outerGeofence)
        monitoredRegions.append(outerGeofence)
        
        LoggingManager.logEvent("createFlowerGeofences")
    }
    
    func removeAllGeofences() {
        for region in monitoredRegions {
            locationManager.stopMonitoring(for: region)
            print("loop")
        }
        monitoredRegions.removeAll()
        LoggingManager.logEvent("removeAllGeofences: \(locationManager.monitoredRegions.count)")
    }
    
    private func calculatePetalCenter(from center: CLLocationCoordinate2D, radius: CLLocationDistance, angle: Double) -> CLLocationCoordinate2D {
        let latitude = center.latitude + (radius / 111_000) * cos(angle) // Approximation for meters to latitude
        let longitude = center.longitude + (radius / (111_000 * cos(center.latitude * .pi / 180))) * sin(angle)
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
