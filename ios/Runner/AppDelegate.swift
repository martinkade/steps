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
            let fitnessHandler = FitnessHandler()
            fitnessHandler.subscribe(toChannel: fitnessChannel, fromController: controller)
            if #available(iOS 10.0, *) {
                let notificationHandler = NotificationHandler(withDelegate: self)
                notificationHandler.subscribe(toChannel: fitnessChannel, fromController: controller)
            }
        }
        
        GeneratedPluginRegistrant.register(with: self)
        let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return result
    }
    
    override func applicationDidBecomeActive(_ application: UIApplication) {
        super.applicationDidBecomeActive(application)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
}

extension AppDelegate {
    
    @available(iOS 10.0, *)
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
    @available(iOS 10.0, *)
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
}
