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
                let queue = DispatchQueue.main
                
                var data = [String: Any?]()
                var activeData: [String: Int]?
                var stepData: [String: Int]?
                
                let group = DispatchGroup()
                
                group.enter()
                self.readTotalStepsMinutes(range: FitnessDateRange.lastWeek) { history in
                    queue.async {
                        stepData = history
                        group.leave()
                    }
                }
                
                group.enter()
                self.readWorkouts(range: FitnessDateRange.lastWeek) { history in
                    queue.async {
                        activeData = history
                        group.leave()
                    }
                }
                
                group.notify(queue: queue) {
                    data["steps"] = stepData
                    data["activeMinutes"] = activeData
                    result(data)
                }
                
            } else if call.method == "isAuthenticated" {
                self.isAuthorized { (authorized) in
                    DispatchQueue.main.async {
                        result(authorized)
                    }
                }
            } else if call.method == "authenticate" {
                self.authorize { (authorized) in
                    DispatchQueue.main.async {
                        result(authorized)
                    }
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
    }
    
    private func isAuthorized(result: @escaping (Bool) -> Void) {
        guard #available(iOS 9.3, *), HKHealthStore.isHealthDataAvailable(), let steps = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else {
            result(false)
            return
        }
        
        let store = HKHealthStore()
        if #available(iOS 12.0, *) {
            let store = HKHealthStore()
            store.getRequestStatusForAuthorization(toShare: [], read: [steps, HKObjectType.workoutType(), HKObjectType.activitySummaryType()]) { (status, error) in
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
            switch store.authorizationStatus(for: steps) {
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
        guard #available(iOS 9.3, *), HKHealthStore.isHealthDataAvailable(), let steps = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else {
            result(false)
            return
        }
        
        let store = HKHealthStore()
        store.requestAuthorization(toShare: [], read: [steps, HKObjectType.workoutType(), HKObjectType.activitySummaryType()]) { (granted, error) in
            if granted {
                result(true)
            } else {
                result(false)
            }
        }
    }
    
    private func readTotalStepsMinutes(range: FitnessDateRange, result: @escaping ([String: Int]) -> Void) {
        guard #available(iOS 9.3, *), let startDate = range.startDate, let endDate = range.endDate, let steps = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else {
            result([:])
            return
        }
        
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(quantityType: steps, quantitySamplePredicate: nil, options: .cumulativeSum, anchorDate: startDate, intervalComponents: interval)
        
        query.initialResultsHandler = { query, results, error in
            guard let results = results, error == nil else {
                result([:])
                return
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            var data = [String: Int]()
            
            var key: String = ""
            var value: Int = 0
            results.enumerateStatistics(from: startDate, to: endDate, with: { statistics, stop in
                if let quantity = statistics.sumQuantity() {
                    key = formatter.string(from: statistics.startDate)
                    value = Int(quantity.doubleValue(for: HKUnit.count()))
                    if let oldValue = data[key] {
                        data[key] = oldValue + value
                    } else {
                        data[key] = value
                    }
                }
            })
            
            result(data)
        }
        
        let store = HKHealthStore()
        store.execute(query)
    }
    
    private func readWorkouts(range: FitnessDateRange, result: @escaping ([String: Int]) -> Void) {
        guard #available(iOS 9.3, *), let startDate = range.startDate, let endDate = range.endDate else {
            result([:])
            return
        }
        
        let datePredicate = HKQuery.predicateForSamples(
          withStart: startDate,
          end: endDate,
          options: [.strictStartDate]
        )
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate])
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        
        let query = HKSampleQuery(
            sampleType: .workoutType(),
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                guard let samples = samples as? [HKWorkout], error == nil else {
                    result([:])
                    return
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                var data = [String: Int]()
                
                var key: String = ""
                var value: Int = 0
                
                for workout in samples {
                    key = formatter.string(from: workout.startDate)
                    value = Int(workout.duration / 60.0)
                    if let oldValue = data[key] {
                        data[key] = oldValue + value
                    } else {
                        data[key] = value
                    }
                }
                
                result([:])
                return
          }

        let store = HKHealthStore()
        store.execute(query)
    }
    
}
