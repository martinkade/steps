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
                var activeData = [String: Int]()
                
                let group = DispatchGroup()
                
                group.enter()
                self.readTotalActiveMinutes(range: FitnessDateRange.today) { (minutes) in
                    queue.async {
                        activeData["today"] = minutes
                        group.leave()
                    }
                }
                
                group.enter()
                self.readTotalActiveMinutes(range: FitnessDateRange.week) { (minutes) in
                    queue.async {
                        activeData["week"] = minutes
                        group.leave()
                    }
                }
                
                group.enter()
                self.readTotalActiveMinutes(range: FitnessDateRange.lastWeek) { (minutes) in
                    queue.async {
                        activeData["lastWeek"] = minutes
                        group.leave()
                    }
                }
                
                group.enter()
                self.readTotalActiveMinutes(range: FitnessDateRange.allTime) { (minutes) in
                    queue.async {
                        activeData["total"] = minutes
                        group.leave()
                    }
                }
                
                group.notify(queue: queue) {
                    self.readWorkouts(range: FitnessDateRange.allTime) { (minutes) in
                        queue.async {
                            activeData["today"] = (activeData["today"] ?? 0) + minutes[0]
                            activeData["week"] = (activeData["week"] ?? 0) + minutes[1]
                            activeData["lastWeek"] = (activeData["lastWeek"] ?? 0) + minutes[2]
                            activeData["total"] = (activeData["total"] ?? 0) + minutes[3]
                            data["activeMinutes"] = activeData
                            result(data)
                        }
                    }
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
    
    private func readTotalActiveMinutes(range: FitnessDateRange, result: @escaping (Int) -> Void) {
        guard #available(iOS 9.3, *), let startDate = range.startDate, let endDate = range.endDate, let steps = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else {
            result(0)
            return
        }

        let datePredicate = HKQuery.predicateForSamples(
          withStart: startDate,
          end: endDate,
          options: [.strictStartDate]
        )
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate])
        
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, queryResult, error) in
            guard let steps = queryResult?.sumQuantity()?.doubleValue(for: HKUnit.count()), error == nil else {
                result(0)
                return
            }
            NSLog("step count=\(steps)")
            result(Int(steps / 80.0))
        }
        
        let store = HKHealthStore()
        store.execute(query)
    }
    
    private func readWorkouts(range: FitnessDateRange, result: @escaping ([Int]) -> Void) {
        guard #available(iOS 9.3, *), let startDate = range.startDate, let endDate = range.endDate else {
            result([0, 0, 0, 0])
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
                    result([0, 0, 0, 0])
                    return
                }
                
                NSLog("found \(samples.count) workouts:")
                
                var today: Int = 0
                var week: Int = 0
                var lastWeek: Int = 0
                var total: Int = 0
                
                var minutes: Int
                for workout in samples {
                    minutes = Int(workout.duration / 60.0)
                    NSLog("found workout \(workout.startDate) => \(minutes) minutes")
                    if workout.startDate.isThisWeek {
                        week += minutes
                        if workout.startDate.isToday {
                            today += minutes
                        }
                    } else if workout.startDate.isLastWeek {
                        lastWeek += minutes
                    }
                    total += minutes
                }
                
                NSLog("minutes=\([today, week, lastWeek, total])")
                result([today, week, lastWeek, total])
                return
          }

        let store = HKHealthStore()
        store.execute(query)
    }
    
}
