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
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
