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
                self.readWorkouts()

                var data = [String: Any?]()
                var activeData = [String: Int]()
                
                let group = DispatchGroup()
                
                group.enter()
                self.readTotalActiveMinutes(range: FitnessDateRange.today) { (minutes) in
                    activeData["today"] = minutes
                    group.leave()
                }
                
                group.enter()
                self.readTotalActiveMinutes(range: FitnessDateRange.week) { (minutes) in
                    activeData["week"] = minutes
                    group.leave()
                }
                
                group.enter()
                self.readTotalActiveMinutes(range: FitnessDateRange.lastWeek) { (minutes) in
                    activeData["lastWeek"] = minutes
                    group.leave()
                }
                
                group.enter()
                self.readTotalActiveMinutes(range: FitnessDateRange.allTime) { (minutes) in
                    activeData["total"] = minutes
                    group.leave()
                }
                
                group.notify(queue: DispatchQueue.main) {
                    data["activeMinutes"] = activeData
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
            guard let steps = queryResult?.sumQuantity()?.doubleValue(for: HKUnit.count()) else {
                result(0)
                return
            }
            result(Int(steps / 80.0))
        }
        
        let store = HKHealthStore()
        store.execute(query)
    }
    
    private func readWorkouts() {
        guard #available(iOS 9.3, *), let _ = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.appleExerciseTime) else {
            return
        }
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let startDate = calendar.startOfDay(for: Date()).addingTimeInterval(-3600 * 24 * 7)
        let endDate = Date()
        
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
                    return
                }
                
                for workout in samples {
                    NSLog("\(workout.startDate) \(Int(workout.duration / 60.0)) minutes of \(workout.workoutActivityType)")
                }
          }

        let store = HKHealthStore()
        store.execute(query)
    }
    
}
