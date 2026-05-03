import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return result
    }
    
    override func applicationDidBecomeActive(_ application: UIApplication) {
        super.applicationDidBecomeActive(application)
        
        application.applicationIconBadgeNumber = 0
    }
    
    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
        
        let fitnessChannel = FlutterMethodChannel(name: "com.mediabeam/fitness", binaryMessenger: engineBridge.applicationRegistrar.messenger())
        let fitnessHandler = FitnessHandler()
        fitnessHandler.subscribe(toChannel: fitnessChannel)
        let notificationChannel = FlutterMethodChannel(name: "com.mediabeam/notification", binaryMessenger: engineBridge.applicationRegistrar.messenger())
        let notificationHandler = NotificationHandler(withDelegate: self)
        notificationHandler.subscribe(toChannel: notificationChannel)
        
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
