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

    private var lastFetchTime: Date = .distantPast
    private var cachedSteps: Double = 0
    private let cacheInterval: TimeInterval = 60
    
    @Published var isAuthorized = false
    @Published var authorizationRequested = false
    
    init() {
        requestHealthKitPermissions()
    }
    
    private func requestHealthKitPermissions() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
        
        let steps = HKQuantityType(.stepCount)
        let healthTypes: Set = [steps]
        
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
                await MainActor.run {
                    self.isAuthorized = true
                    self.authorizationRequested = true
                    print("HealthKit authorization granted")
                
                    self.fetchTodayStepsWithCaching { steps in
                        print("Initial steps fetch after authorization: \(steps)")
                    }
                }
            } catch {
                await MainActor.run {
                    self.authorizationRequested = true
                    print("HealthKit authorization error: \(error)")
                }
            }
        }
    }
    
   
    func fetchTodayStepsWithCaching(completion: @escaping (Double) -> Void) {
        let now = Date()
        
        
        if now.timeIntervalSince(lastFetchTime) < cacheInterval && cachedSteps > 0 {
            print("HealthKitManager: using cached steps: \(cachedSteps)")
            completion(cachedSteps)
            return
        }
        

        fetchTodaySteps { [weak self] steps in
            self?.lastFetchTime = now
            self?.cachedSteps = steps
            completion(steps)
        }
    }
    
    
    func fetchTodaySteps(completion: @escaping (Double) -> Void) {
        guard isAuthorized else {
            print("HealthKit not authorized")
            completion(0)
            return
        }
        
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
    
 
    func forceRefreshSteps(completion: @escaping (Double) -> Void) {
        lastFetchTime = .distantPast
        cachedSteps = 0
        fetchTodayStepsWithCaching(completion: completion)
    }
    
    func clearCache() {
        lastFetchTime = .distantPast
        cachedSteps = 0
    }
}
