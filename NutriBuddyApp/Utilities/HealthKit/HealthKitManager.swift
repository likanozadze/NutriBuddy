//
//  HealthKitManager.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/27/25.
//

import Foundation
import HealthKit

extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
}

class HealthKitManager: ObservableObject {
    
    let healthStore = HKHealthStore()

    
    init() {
        let steps = HKQuantityType(.stepCount)
        let healthTypes: Set = [steps]
        
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
            } catch {
                print("error fetching health data")
            }
        }
    }
    
    func fetchTodaySteps(completion: @escaping (Double) -> Void) {
            print("HealthKitManager: fetchTodaySteps called")
            let steps = HKQuantityType(.stepCount)
            let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
            let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, result, error in
                guard let quantity = result?.sumQuantity(), error == nil else {
                    print("HealthKitManager: error fetching todays step data: \(String(describing: error))")
                    DispatchQueue.main.async {
                        completion(0)
                    }
                    return
                }
                let stepCount = quantity.doubleValue(for: .count())
                print("HealthKitManager: fetched step count: \(stepCount)")
                
                DispatchQueue.main.async {
                    print("HealthKitManager: calling completion with steps: \(stepCount)")
                    completion(stepCount)
                }
            }
            healthStore.execute(query)
        }
    }

