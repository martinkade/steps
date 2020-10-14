//
//  NotificationHandler.swift
//  Runner
//
//  Created by mediaBEAM on 16.09.20.
//

import UIKit
import Flutter

@available(iOS 10.0, *)
class NotificationHandler: NSObject {
    
    private let delegate: UNUserNotificationCenterDelegate
    
    init(withDelegate delegate: UNUserNotificationCenterDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    @objc func subscribe(toChannel channel: FlutterMethodChannel, fromController controller: FlutterViewController) {
        channel.setMethodCallHandler({ (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "isNotificationsEnabled" {
                self.isAuthorized { (enabled) in
                    DispatchQueue.main.async {
                        result(enabled)
                    }
                }
            } else if call.method == "enableNotifications" {
                self.authorize(((call.arguments as? [String: Any?])?["enable"] as? Bool) ?? false) { (enabled) in
                    DispatchQueue.main.async {
                        result(enabled)
                    }
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
    }
    
    fileprivate func authorize(_ enable: Bool, withCompletion completion: @escaping (Bool) -> Void) {
        if enable {
            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.delegate = delegate
            notificationCenter.requestAuthorization(options: options) { granted, error in
                let enabled = error == nil && granted
                if enabled {
                    self.scheduleWeeklyNotification()
                } else {
                    self.cancelPendingNotifications()
                }
                UserDefaults.standard.set(enabled, forKey: "notifications")
                completion(enabled)
            }
        } else {
            cancelPendingNotifications()
            UserDefaults.standard.set(false, forKey: "notifications")
            completion(false)
        }
    }
    
    fileprivate func isAuthorized(withCompletion completion: @escaping (Bool) -> Void) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = delegate
        notificationCenter.getNotificationSettings { settings in
            completion(settings.authorizationStatus == .authorized && UserDefaults.standard.bool(forKey: "notifications"))
        }
    }
    
    fileprivate func cancelPendingNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["af68938f-eca7-4651-87b5-0d15eb3d8d88"])
    }
    
    fileprivate func scheduleWeeklyNotification() {
        cancelPendingNotifications()
        
        let content = UNMutableNotificationContent()
        
        content.title = NSLocalizedString("lblNotificationWeeklyResults", comment: "")
        content.body = NSLocalizedString("lblNotificationWeeklyResultsInfo", comment: "")
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        
        // dateComponents.weekday = 2 // Monday
        dateComponents.hour = 7
        dateComponents.minute = 30
        dateComponents.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let uuidString = "af68938f-eca7-4651-87b5-0d15eb3d8d88"
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = delegate
        notificationCenter.add(request) { error in
            if error != nil { }
        }
    }
    
}
