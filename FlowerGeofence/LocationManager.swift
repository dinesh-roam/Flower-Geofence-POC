import CoreLocation

class LocationManager: NSObject, LocationService {
    
    static let shared = LocationManager()
    
    private var locationManager = CLLocationManager()
    weak var delegate: LocationServiceDelegate?
    var lastLocation: CLLocation?
    private let notificationService: NotificationService = LocalNotificationManager()

    
    
    private override init() {
        super.init()
        configureLocationManager()
    }
    
    public func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 30
        locationManager.pausesLocationUpdatesAutomatically = false
//        locationManager.allowsBackgroundLocationUpdates = false // Ensure background updates
        locationManager.showsBackgroundLocationIndicator = false
//        locationManager?.requestAlwaysAuthorization() // Request 'Always' permission for full functionality
        
    }
    
    func requestAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func requestLocationPermissions() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startTracking() {
        // Request the current location once
        LoggingManager.logEvent(#function)
//        locationManager.delegate = self
        locationManager.requestLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startMonitoringVisits()
//        locationManager.startUpdatingLocation()
        
    }

    func stopTracking(){
        LoggingManager.logEvent(#function)
//        locationManager.delegate = nil
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        stopMonitoringAllGeofences()
        lastLocation = nil
        
        
        
    }

    func updateGeofence(location: CLLocation) {
        
        // Calculate the distance between the last known location and the current location
        if let lastLocation = lastLocation {
            let distance = location.distance(from: lastLocation)
            LoggingManager.logEvent("Distance between last and current location: \(distance) meters")
        }
        
        lastLocation = location
        stopMonitoringAllGeofences()
        // Step 3: Create geofences when the location is updated
        let defaults = UserDefaults.standard
        let innerRadius: CLLocationDistance = defaults.double(forKey: "innerRadius")
        createFlowerGeofences(at: location.coordinate, innerRadius: innerRadius)
    }
    
    func logMonitoredRegions() {
        locationManager.monitoredRegions.forEach { region in
            LoggingManager.logEvent("Currently monitored geofence: \(region.identifier)")
        }
    }
    
    func stopMonitoringAllGeofences() {
        locationManager.monitoredRegions.forEach {
            if locationManager.monitoredRegions.contains($0) {
                locationManager.stopMonitoring(for: $0)
                LoggingManager.logEvent("Successfully stopped geofence: \($0.identifier)")
            } else {
                LoggingManager.logEvent("Geofence not found in monitoredRegions: \($0.identifier)")
            }
        }
        LoggingManager.logEvent("After stopping: \(locationManager.monitoredRegions.count) geofences still monitored")
    }
}

extension LocationManager: CLLocationManagerDelegate {
        
    // Handle permission changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let now = CLLocation(latitude: 77.08579067335893, longitude: 28.55596543900536)
        let old = CLLocation(latitude: 77.08584190384947, longitude: 28.555857507342697)
        let distance = now.distance(from: old)
        print(distance, "meters")
        print(kCLLocationAccuracyBest)
        print(kCLLocationAccuracyNearestTenMeters)
        
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            LoggingManager.logEvent("Location access not determined")
            locationManager.requestWhenInUseAuthorization() // Request permission for when in use
        case .restricted, .denied:
            // Handle the case when permission is denied or restricted
            LoggingManager.logEvent("Location permission denied/restricted")
        case .authorizedWhenInUse:
            LoggingManager.logEvent("Location access granted: When in use")
            locationManager.requestAlwaysAuthorization() // Request always authorization if already authorized for when in use
        case .authorizedAlways:
            // Already authorized for always
            LoggingManager.logEvent("Location access granted: Always")
            startTracking()
            break
        @unknown default:
            fatalError("Unknown authorization status")
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        manager.requestLocation()
        notificationService.sendNotification(title: "📍Entered Region", body: "")
        guard let identifier = region.identifier as String?, let location = manager.location else {
            locationManager.requestLocation()
            return
        }
//        locationManager.requestLocation()
        delegate?.didEnterGeofence(identifier: identifier, at: location)
        updateGeofence(location: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        notificationService.sendNotification(title: "📍Exited Region", body: "")
        guard let identifier = region.identifier as String?, let location = manager.location else {
            locationManager.requestLocation()
            return
        }
//        locationManager.requestLocation()
        delegate?.didExitGeofence(identifier: identifier, at: location)
        updateGeofence(location: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: (any Error)?) {
        print(#function)
        LoggingManager.logEvent("-->>>\( #function)")
        if let error = error {
            LoggingManager.logError(error)
        }
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print(#function)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
//        print(#function, state.rawValue)
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
//        print(#function, region.identifier)
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print(#function)
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        logVisit(visit, location: manager.location!)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        notificationService.sendNotification(title: "📍Location Update", body: "")
        if let location = locations.last {
            delegate?.didUpdateLocation(location)
            updateGeofence(location: location)
        }
    }
        
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.didFail(with: error)
        LoggingManager.logError(error)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: any Error) {
        LoggingManager.logError(error)
    }
    
    func logVisit(_ visit: CLVisit, location:CLLocation?) {
        saveVisitDataToCSV(visit: visit, location: location!)
        // Create a log message with visit details
        let arrivalDate = visit.arrivalDate != Date.distantPast ? visit.arrivalDate : nil
        let departureDate = visit.departureDate != Date.distantFuture ? visit.departureDate : nil
        
        let visitDescription = """
               Vist(Lat/Long): \(visit.coordinate.latitude) , \(visit.coordinate.longitude)
               HorizontalAccuracy: \(visit.horizontalAccuracy)
               Arrival: \(arrivalDate?.description ?? "Unknown")
               Departure: \(departureDate?.description ?? "Unknown")
               RecordedAt: \(Date())
               "---------------"Location Manager "------------------"
               (Lat/Long): \(location?.coordinate.latitude ?? 0), \(location?.coordinate.longitude ?? 0)
               HorizontalAccuracy: \(location?.horizontalAccuracy ?? 0)
               LocationTimestamp: \(location?.timestamp.description ?? "")
               """
        
        // Log visit details
        LoggingManager.logEvent(visitDescription)
        notificationService.sendNotification(title: "📍 New Visit Logged", body: visitDescription)
    }

}


extension LocationManager {
    func createFlowerGeofences(at location: CLLocationCoordinate2D, innerRadius: CLLocationDistance) {
        delegate?.didCreateGeofence(identifier: "jh", at: CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        //30,30,90    20
        //25,30,90    25            (Avg: Disnatce interval 25 - 28)
        //20,30,90    30            (Avg: Disnatce interval 25 - 28)
        
//        let petalOffset = innerRadius * 0.5         // Offset for petals from the inner geofence (50% of innerRadius)
//        let petalRadius = innerRadius * 0.8        // Radius of each petal geofence (30% of innerRadius)
//        let outerOffset = innerRadius * 0.2         // Offset for outer geofence from the petals (20% of innerRadius)
        
        let petalOffset = innerRadius * GeofenceConstants.petalOffset     // Offset for petals from the inner geofence (50% of innerRadius)
        let petalRadius = innerRadius * GeofenceConstants.petalRadius        // Radius of each petal geofence (30% of innerRadius)
        let outerOffset = innerRadius * GeofenceConstants.outerOffset        // Offset for outer geofence from the petals (20% of innerRadius)
        let outerRadius = innerRadius + petalOffset + petalRadius + outerOffset
        
        
//        let defaults = UserDefaults.standard
//        let petalOffset: CLLocationDistance = defaults.double(forKey: "petalOffset")/// Offset for petals from the inner geofence
//        let petalRadius: CLLocationDistance = defaults.double(forKey: "petalRadius") /// Radius of each petal geofence
//        let outerOffset: CLLocationDistance = 10 /// Offset for outer geofence from the petals
        let numberOfPetals = 6
        
        // Inner geofence
        let innerGeofence = CLCircularRegion(center: location, radius: innerRadius, identifier: "InnerGeofence")
        innerGeofence.notifyOnExit = true
        innerGeofence.notifyOnEntry = false
        locationManager.startMonitoring(for: innerGeofence)

        // Petal geofences
        let angleStep = 360.0 / Double(numberOfPetals)
        for i in 0..<numberOfPetals {
            let angle = angleStep * Double(i) * .pi / 180.0
            let petalCenter = calculatePetalCenter(from: location, radius: innerRadius + petalOffset, angle: angle)
            let petalGeofence = CLCircularRegion(center: petalCenter, radius: petalRadius, identifier: "PetalGeofence-\(i)")
            petalGeofence.notifyOnExit = false
            petalGeofence.notifyOnEntry = true
            locationManager.startMonitoring(for: petalGeofence)
        }
        
        // Outer geofence
//        let outerRadius = innerRadius + petalOffset + petalRadius + outerOffset
        let outerGeofence = CLCircularRegion(center: location, radius: outerRadius, identifier: "OuterGeofence")
        outerGeofence.notifyOnExit = true
        outerGeofence.notifyOnEntry = false
//        locationManager.startMonitoring(for: outerGeofence)
        
        LoggingManager.logEvent("createFlowerGeofences")

    }
    
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


extension LocationManager {
    // Save visit and location data as CSV entry
    func saveVisitDataToCSV(visit: CLVisit, location: CLLocation) {
        // Ensure we have a valid CSV file URL
        guard let fileURL = createCSVFile() else { return }
        
        // Prepare the visit and location data
        let arrivalDate = visit.arrivalDate == .distantPast ? "N/A" : "\(visit.arrivalDate)"
        let departureDate = visit.departureDate == .distantFuture ? "N/A" : "\(visit.departureDate)"
        
        let visitData = [
            arrivalDate, // Visit arrival date
            departureDate, // Visit departure date
            "\(visit.coordinate.latitude)", // Visit latitude
            "\(visit.coordinate.longitude)", // Visit longitude
            "\(visit.horizontalAccuracy)" // Visit accuracy
        ]
        
        let locationData = [
            "\(location.timestamp)", // Location timestamp
            "\(location.coordinate.latitude)", // Location latitude
            "\(location.coordinate.longitude)", // Location longitude
            "\(location.horizontalAccuracy)" // Location accuracy
        ]
        
        // Combine visit and location data into a single row
        let csvRow = (visitData + locationData).joined(separator: ",") + "\n"
        
        // Append the data to the CSV file
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                // Append to existing file
                let fileHandle = try FileHandle(forWritingTo: fileURL)
                fileHandle.seekToEndOfFile()
                if let csvData = csvRow.data(using: .utf8) {
                    fileHandle.write(csvData)
                }
                fileHandle.closeFile()
            } else {
                // Write headers and data if file doesn't exist
                let headers = "Arrival Date,Departure Date,Visit Latitude,Visit Longitude,Visit Accuracy,Location Timestamp,Location Latitude,Location Longitude,Location Accuracy\n"
                let initialData = headers + csvRow
                try initialData.write(to: fileURL, atomically: true, encoding: .utf8)
            }
        } catch {
            print("Failed to write to CSV file: \(error)")
        }
    }
    
    // Create a CSV file path in the temporary directory
    func createCSVFile() -> URL? {
        let fileName = "VisitData.csv"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        return path
    }
}



