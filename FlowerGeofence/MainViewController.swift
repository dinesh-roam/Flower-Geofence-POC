//
//  MainViewController.swift
//  FlowerGeofence
//
//  Created by Dinesh Kumar A on 20/10/24.
//

import UIKit
import CoreLocation


class MainViewController: UIViewController, MapViewControllerDelegate {
    
    // Dependencies
    var locationService: LocationService!
    
    var lastKnownLocation: CLLocation?
    var currentGeofenceEvents: [String: CLLocation] = [:]
    var csvFileURL: URL?
    
    // UI Components
    lazy var startTrackingButton: UIButton = {
        let bt = UIButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.setTitle("Start Tracking", for: .normal)
        bt.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        bt.backgroundColor = .systemBlue
        bt.addTarget(self, action: #selector(startTracking), for: .touchUpInside)
        bt.addTarget(self, action: #selector(didTouchDown(_:)), for: .touchDown)
        bt.addTarget(self, action: #selector(didTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
            
        bt.layer.cornerRadius = 5
        return bt
    }()
    
    // UI Components
    lazy var stopTrackingButton: UIButton = {
        let bt = UIButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.setTitle("Stop Tracking", for: .normal)
        bt.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        bt.backgroundColor = .systemBlue
        bt.addTarget(self, action: #selector(StopTracking), for: .touchUpInside)
        bt.addTarget(self, action: #selector(didTouchDown(_:)), for: .touchDown)
        bt.addTarget(self, action: #selector(didTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        bt.layer.cornerRadius = 5
        return bt
    }()
    
    // UI Components
    lazy var mapButton: UIButton = {
        let bt = UIButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.setTitle("Map ", for: .normal)
        bt.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        bt.backgroundColor = .systemBlue
        bt.addTarget(self, action: #selector(openMap), for: .touchUpInside)
        bt.addTarget(self, action: #selector(didTouchDown(_:)), for: .touchDown)
        bt.addTarget(self, action: #selector(didTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        bt.layer.cornerRadius = 5
        return bt
    }()
    
    // UI Components
    lazy var permissionButton: UIButton = {
        let bt = UIButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.setTitle("Request Permission", for: .normal)
        bt.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        bt.backgroundColor = .systemBlue
        bt.addTarget(self, action: #selector(requestPermission), for: .touchUpInside)
        bt.addTarget(self, action: #selector(didTouchDown(_:)), for: .touchDown)
        bt.addTarget(self, action: #selector(didTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        bt.layer.cornerRadius = 5
        return bt
    }()
    
    // UI Components
    lazy var shareDataButton: UIButton = {
        let bt = UIButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.setTitle("Share Data", for: .normal)
        bt.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        bt.backgroundColor = .systemBlue
        bt.addTarget(self, action: #selector(shareCSV), for: .touchUpInside)
        bt.addTarget(self, action: #selector(didTouchDown(_:)), for: .touchDown)
        bt.addTarget(self, action: #selector(didTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        bt.layer.cornerRadius = 5
        return bt
    }()
    
    // UI Components
    lazy var ClearDataButton: UIButton = {
        let bt = UIButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.setTitle("Clear Data", for: .normal)
        bt.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        bt.backgroundColor = .systemBlue
        bt.addTarget(self, action: #selector(clearCSVData), for: .touchUpInside)
        bt.addTarget(self, action: #selector(didTouchDown(_:)), for: .touchDown)
        bt.addTarget(self, action: #selector(didTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        bt.layer.cornerRadius = 5
        return bt
    }()
    
    // UI Components
    lazy var configureButton: UIButton = {
        let bt = UIButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.setTitle("Configure", for: .normal)
        bt.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        bt.backgroundColor = .systemBlue
        bt.addTarget(self, action: #selector(configureAction), for: .touchUpInside)
        bt.addTarget(self, action: #selector(didTouchDown(_:)), for: .touchDown)
        bt.addTarget(self, action: #selector(didTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        bt.layer.cornerRadius = 5
        return bt
    }()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        locationService.delegate = self
        
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(startTrackingButton)
        view.addSubview(stopTrackingButton)
        view.addSubview(permissionButton)
        view.addSubview(mapButton)
        view.addSubview(shareDataButton)
        view.addSubview(ClearDataButton)
        view.addSubview(configureButton)
        
        NSLayoutConstraint.activate([
           
            startTrackingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startTrackingButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            startTrackingButton.heightAnchor.constraint(equalToConstant: 50),
            startTrackingButton.widthAnchor.constraint(equalToConstant: 200),
            
            stopTrackingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stopTrackingButton.topAnchor.constraint(equalTo: startTrackingButton.bottomAnchor, constant: 40),
            stopTrackingButton.heightAnchor.constraint(equalToConstant: 50),
            stopTrackingButton.widthAnchor.constraint(equalToConstant: 200),
            
            permissionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            permissionButton.topAnchor.constraint(equalTo: stopTrackingButton.bottomAnchor, constant: 40),
            permissionButton.heightAnchor.constraint(equalToConstant: 50),
            permissionButton.widthAnchor.constraint(equalToConstant: 200),
            
            mapButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mapButton.topAnchor.constraint(equalTo: permissionButton.bottomAnchor, constant: 40),
            mapButton.heightAnchor.constraint(equalToConstant: 50),
            mapButton.widthAnchor.constraint(equalToConstant: 200),
            
            shareDataButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareDataButton.topAnchor.constraint(equalTo: mapButton.bottomAnchor, constant: 40),
            shareDataButton.heightAnchor.constraint(equalToConstant: 50),
            shareDataButton.widthAnchor.constraint(equalToConstant: 200),
            
            ClearDataButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ClearDataButton.topAnchor.constraint(equalTo: shareDataButton.bottomAnchor, constant: 40),
            ClearDataButton.heightAnchor.constraint(equalToConstant: 50),
            ClearDataButton.widthAnchor.constraint(equalToConstant: 200),
            
            configureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            configureButton.topAnchor.constraint(equalTo: ClearDataButton.bottomAnchor, constant: 40),
            configureButton.heightAnchor.constraint(equalToConstant: 50),
            configureButton.widthAnchor.constraint(equalToConstant: 200),
            
            
        ])
    }
    
    // Methods to add press feedback
    @objc private func didTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.backgroundColor = sender.backgroundColor?.withAlphaComponent(0.7) // Darken the button color
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) // Slightly shrink button
        }
    }

    @objc private func didTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.backgroundColor = sender.backgroundColor?.withAlphaComponent(1.0) // Restore original color
            sender.transform = .identity // Restore button size
        }
    }
    
    @objc private func startTracking() {
        
        locationService.startTracking()
        lastKnownLocation = nil
    }
    
    @objc private func StopTracking() {
        locationService.stopTracking()
        lastKnownLocation = nil
    }

    
    @objc private func requestPermission() {
        locationService.requestLocationPermissions()
    }
    
    @objc private func openMap() {
//        let mapVC = MapViewController()
        let mapVC = CentroidMapViewController()
//        mapVC.lastKnownLocation = lastKnownLocation
        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @objc private func configureAction() {
        let flowerPatternVC = FlowerPatternViewController()
        navigationController?.pushViewController(flowerPatternVC, animated: true)

    }
    
    // Share the CSV file
        @objc func shareCSV() {
            guard let csvURL = LocationManager.shared.createCSVFile() else {
                LoggingManager.logEvent("No CSV file available for sharing.")
                return
            }
            print(csvURL)
            let activityVC = UIActivityViewController(activityItems: [csvURL], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view // for iPad compatibility
            self.present(activityVC, animated: true, completion: nil)
        }
    
    func clearCSVData1() {
          guard let fileURL = csvFileURL else {
              LoggingManager.logEvent("No CSV file to clear.")
              return
          }
          
          do {
              // Check if file exists
              if FileManager.default.fileExists(atPath: fileURL.path) {
                  // Option: Overwrite the file with the headers (keeping the headers)
                  let headers = "Latitude,Longitude,Horizontal Accuracy,Speed,Recorded At,lateral distance from previous location\n"
                  try headers.write(to: fileURL, atomically: true, encoding: .utf8)
                  LoggingManager.logEvent("CSV data cleared (retaining headers).")
              }
              
          } catch {
              LoggingManager.logError(error)
          }
      }
    
    // Method to clear the CSV file data
       @objc func clearCSVData() {
           guard let fileURL = csvFileURL else {
               LoggingManager.logEvent("No CSV file to clear.")
               return
           }
           
           do {
               // Option 1: Delete the file
               if FileManager.default.fileExists(atPath: fileURL.path) {
                   try FileManager.default.removeItem(at: fileURL)
                   csvFileURL = nil
                   LoggingManager.logEvent("CSV data cleared (file deleted).")
               }
               
               // Option 2: Overwrite the file with empty content (keeping the headers)
               // If you want to retain the headers in the CSV:
               // let headers = "Latitude,Longitude,Horizontal Accuracy,Speed,Recorded At\n"
               // try headers.write(to: fileURL, atomically: true, encoding: .utf8)
               // LoggingManager.logEvent("CSV data cleared (retaining headers).")
               
           } catch {
               LoggingManager.logError(error)
           }
       }
}

extension MainViewController: LocationServiceDelegate {
    func didCreateGeofence(identifier: String, at location: CLLocation) {
        NotificationCenter.default.post(name: Notification.Name("CreatedGeofence"), object: (identifier, location))
    }
    
    func didUpdateLocation(_ location: CLLocation) {
        LoggingManager.logEvent("New location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        // Post notification for location update
        NotificationCenter.default.post(name: .locationUpdated, object: location)
        saveLocationDataToCSV(location: location)
    }
    
    func didEnterGeofence(identifier: String, at location: CLLocation) {
        LoggingManager.logEvent("Entered geofence with ID: \(identifier) at location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        // Post notification for geofence entry
        NotificationCenter.default.post(name: Notification.Name("GeofenceEntered"), object: (identifier, location))
        saveLocationDataToCSV(location: location)
    }
    
    func didExitGeofence(identifier: String, at location: CLLocation) {
        LoggingManager.logEvent("Exited geofence with ID: \(identifier) at location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        // Post notification for geofence exit
        NotificationCenter.default.post(name: Notification.Name("GeofenceExited"), object: (identifier, location))
        saveLocationDataToCSV(location: location)
    }
    
    func didFail(with error: Error) {
        LoggingManager.logEvent("Location error: \(error.localizedDescription)")
    }
}

extension MainViewController {
    // Method to handle location updates
    func saveLocationDataToCSV(location: CLLocation) {
        
        var difference = ""
        
        // Calculate the distance between the last known location and the current location
        if let lastLocation = lastKnownLocation {
            let distance = location.distance(from: lastLocation)
            difference = "\(distance)"
//            LoggingManager.logEvent("Distance between last and current location: \(distance) meters")
        }else{
            difference = ""
        }
        
        lastKnownLocation = location
        
        
        let coordinate = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        let accuracy = "\(location.horizontalAccuracy)"
        let speed = "\(location.speed)"
        let locationTime = "\(location.timestamp)"
        let timestamp = Date().iso8601
       
        


        let csvLine = "\(coordinate),\(accuracy),\(speed),\(locationTime),\(timestamp),\(difference)\n"

        if csvFileURL == nil {
            // If no CSV file exists yet, create it
            csvFileURL = createCSVFile()
        }

        if let fileURL = csvFileURL {
            do {
                // Check if file exists
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    // File exists, append the data
                    let fileHandle = try FileHandle(forWritingTo: fileURL)
                    fileHandle.seekToEndOfFile()
                    if let csvData = csvLine.data(using: .utf8) {
                        fileHandle.write(csvData)
                    }
                    fileHandle.closeFile()
                } else {
                    // If file does not exist, create it with headers
                    let headers = "Latitude,Longitude,Horizontal Accuracy,Speed,Location Time,Recorded At,lateral distance from previous location\n"
                    let fullData = headers + csvLine
                    try fullData.write(to: fileURL, atomically: true, encoding: .utf8)
                }
                LoggingManager.logEvent("Location saved to CSV: \(csvLine)")
            } catch {
                LoggingManager.logError(error)
            }
        }
    }

    // Create a CSV file
    func createCSVFile() -> URL? {
        let fileName = "LocationData.csv"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        return path
    }

}
