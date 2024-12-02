//
//  Utils.swift
//  FlowerGeofence
//
//  Created by Dinesh Kumar A on 19/10/24.
//

import Foundation
import CoreLocation


// Location service protocol to be implemented by LocationManager
protocol LocationService {
    func requestAuthorization()
    func requestLocationPermissions()
    func stopMonitoringAllGeofences()
    func stopTracking()
    func startTracking()
    var delegate: LocationServiceDelegate? { get set }
}

protocol LocationServiceDelegate: AnyObject {
    func didEnterGeofence(identifier: String, at location: CLLocation)
    func didExitGeofence(identifier: String, at location: CLLocation)
    func didFail(with error: Error)
    func didUpdateLocation(_ location: CLLocation)
    func didCreateGeofence(identifier: String, at location: CLLocation)
}

// Tracking logic for creating flower-shaped geofences
protocol GeofenceTracking {
    func createFlowerGeofences(at location: CLLocationCoordinate2D, innerRadius: CLLocationDistance)
    func removeAllGeofences()
}
