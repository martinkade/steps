//
//  FitnessHandler.swift
//  Runner
//
//  Created by mediaBEAM on 17.08.20.
//

import UIKit
import Flutter
import HealthKit

class FitnessHandler: NSObject {

    @objc func subscribe(toChannel channel: FlutterMethodChannel, fromController controller: FlutterViewController) {
        channel.setMethodCallHandler({ (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "getFitnessMetrics" {
                self.readActiveMinutes { (data) in
                    result(data)
                }
            } else if call.method == "isAuthenticated" {
                self.isAuthorized { (authorized) in
                    result(authorized)
                }
            } else if call.method == "authenticate" {
                self.authorize { (authorized) in
                    result(authorized)
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
    }
    
    private func isAuthorized(result: @escaping (Bool) -> Void) {
        guard #available(iOS 9.3, *), HKHealthStore.isHealthDataAvailable(), let activeMinutes = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.appleExerciseTime) else {
            result(false)
            return
        }
        
        let store = HKHealthStore()
        if #available(iOS 12.0, *) {
            let store = HKHealthStore()
            store.getRequestStatusForAuthorization(toShare: [], read: [activeMinutes]) { (status, error) in
                switch status {
                case .unnecessary:
                    result(true)
                    break
                default:
                    result(false)
                    break
                }
            }
        } else {
            switch store.authorizationStatus(for: activeMinutes) {
            case .sharingAuthorized:
                result(true)
                break
            default:
                result(false)
                break
            }
        }
    }
    
    private func authorize(result: @escaping (Bool) -> Void) {
        guard #available(iOS 9.3, *), HKHealthStore.isHealthDataAvailable(), let activeMinutes = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.appleExerciseTime) else {
            result(false)
            return
        }
        
        let store = HKHealthStore()
        store.requestAuthorization(toShare: [], read: [activeMinutes]) { (granted, error) in
            if granted {
                result(true)
            } else {
                result(false)
            }
        }
    }
    
    // https://stackoverflow.com/questions/36559581/healthkit-swift-getting-todays-steps
    private func readActiveMinutes(result: @escaping ([String: Any?]) -> Void) {
        var data = [String: Any?]()
        guard #available(iOS 9.3, *), let activeMinutes = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.appleExerciseTime) else {
            var activeData = [String: Int]()
            activeData["today"] = 0
            activeData["week"] = 0
            activeData["lastWeek"] = 0
            activeData["total"] = 0
            data["activeMinutes"] = activeData
            result(data)
            return
        }
        
        let startDate = Calendar.current.startOfDay(for: Date()).addingTimeInterval(-3600 * 24 * 2)
        let endDate = Date()

        let predicate = HKQuery.predicateForSamples(
          withStart: startDate,
          end: endDate,
          options: [.strictStartDate, .strictEndDate]
        )

        // interval is 1 day
        var interval = DateComponents()
        interval.day = 1

        let query = HKStatisticsQuery(quantityType: activeMinutes, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, queryResult, error) in
            guard let sum = queryResult?.sumQuantity()?.doubleValue(for: HKUnit.minute()) else {
                var activeData = [String: Int]()
                activeData["today"] = 0
                activeData["week"] = 0
                activeData["lastWeek"] = 0
                activeData["total"] = 0
                data["activeMinutes"] = activeData
                result(data)
                return
            }

            NSLog("minutes: \(sum)")
        }
        
        let store = HKHealthStore()
        store.execute(query)
         
        var activeData = [String: Int]()
        activeData["today"] = 0
        activeData["week"] = 0
        activeData["lastWeek"] = 0
        activeData["total"] = 0
        data["activeMinutes"] = activeData
        
        result(data)
    }
    
}
