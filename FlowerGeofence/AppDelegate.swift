//
//  AppDelegate.swift
//  FlowerGeofence
//
//  Created by Dinesh Kumar A on 19/10/24.
//

import UIKit
import CoreLocation

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().delegate = self;
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("D'oh: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        
        LocationManager.shared.configureLocationManager()
        
        if let _ = launchOptions?[.location] {
                    // Handle location update relaunch
            
            print("Launched by location")
            
                }

        getNetworkStatus { status in
            print("Current network status: \(status)")
        }
        
        
        // Example Usage
        let points = [
            LocationCoordinate(latitude: 12.914788, longitude: 77.635686),
            LocationCoordinate(latitude: 12.914240, longitude: 77.635714),
            LocationCoordinate(latitude: 12.913978, longitude: 77.635407),
            LocationCoordinate(latitude: 12.914356, longitude: 77.635227),
            LocationCoordinate(latitude: 12.914524, longitude: 77.635319)
        ]

        if let centroid = kMeansCentroid(points: points) {
            print("Centroid: Latitude = \(centroid.latitude), Longitude = \(centroid.longitude)")
        } else {
            print("Could not calculate centroid.")
        }

//        12.914788, 77.635686
//        12.914240, 77.635714
//        12.913978, 77.635407
//        12.914356, 77.635227
//        12.914524, 77.635319
//        Centroid: Latitude = 12.91424, Longitude = 77.635714

        let newLocation = CLLocation(latitude: 77.7175634287818, longitude: 12.964776025142271)
        print("Distance",newLocation.distance(from: newLocation) < 30.0)
        print()
        

         
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // Handle notification while the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show the notification as a banner even if the app is in the foreground
        completionHandler([.alert, .sound])
    }
    
    // Handle when a user taps on a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Process the notification response, such as navigating to a specific screen
        print("Notification received with identifier: \(response.notification.request.identifier)")
        
        completionHandler()
    }


}


import Network

func getNetworkStatus(completion: @escaping (String) -> Void) {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "NetworkMonitorQueue")
    
    monitor.pathUpdateHandler = { path in
        if path.status == .satisfied {
            // Check for WiFi
            if path.availableInterfaces.contains(where: { $0.type == .wifi }) {
                completion("WiFi")
            }
            // Check for Cellular
            else if path.availableInterfaces.contains(where: { $0.type == .cellular }) {
                completion("Cellular")
            }
        } else {
            completion("No Network")
        }
    }
    
    monitor.start(queue: queue)
}
