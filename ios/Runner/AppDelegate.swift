import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        if let controller = window?.rootViewController as? FlutterViewController {
            let fitnessChannel = FlutterMethodChannel(name: "com.mediabeam/fitness", binaryMessenger: controller.binaryMessenger)
            let handler = FitnessHandler()
            handler.subscribe(toChannel: fitnessChannel, fromController: controller)
        }
        
        GeneratedPluginRegistrant.register(with: self)
        let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        if #available(iOS 10.0, *) {
            authorizeNotifications { granted in
                if granted {
                    self.scheduleWeeklyNotification()
                }
            }
        }
        
        return result
    }
    
    override func applicationDidBecomeActive(_ application: UIApplication) {
        super.applicationDidBecomeActive(application)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
}

extension AppDelegate {
    
    @available(iOS 10.0, *)
    fileprivate func authorizeNotifications(withCompletion completion: @escaping (Bool) -> Void) {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: options) { granted, error in
            completion(error == nil && granted)
        }
    }
    
    @available(iOS 10.0, *)
    fileprivate func isNotificationsAuthorized(withCompletion completion: @escaping (Bool) -> Void) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        notificationCenter.getNotificationSettings { settings in
            completion(settings.authorizationStatus == .authorized)
        }
    }
    
    @available(iOS 10.0, *)
    fileprivate func scheduleWeeklyNotification() {
        let content = UNMutableNotificationContent()
        
        content.title = NSLocalizedString("lblNotificationWeeklyResults", comment: "")
        content.body = NSLocalizedString("lblNotificationWeeklyResultsInfo", comment: "")
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        
        dateComponents.weekday = 2
        dateComponents.hour = 9
        
        // let date = Date(timeIntervalSinceNow: 10)
        // dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        notificationCenter.add(request) { error in
            if error != nil { }
        }
    }
    
    @available(iOS 10.0, *)
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
    @available(iOS 10.0, *)
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler()
    }
    
}
