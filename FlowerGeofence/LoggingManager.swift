//
//  LoggingManager.swift
//  FlowerGeofence
//
//  Created by Dinesh Kumar A on 20/10/24.
//

import Foundation
import OSLog
import UserNotifications


class LoggingManager {
    static func logError(_ error: Error) {
        print("Error occurred: \(error.localizedDescription)")
        // Save to file, analytics, etc.
    }
    
    static func logEvent(_ event: String) {
//        print("Event: \(event)")
        os_log("%@", log: .default, type: .debug, event)
        // Save to file, analytics, etc.
    }
}

protocol NotificationService {
    func sendNotification(title: String, body: String)
}

// MARK: - Local Notification Manager
class LocalNotificationManager: NotificationService {
    init() {
        requestNotificationPermission()
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }
}
