import Foundation
import HealthKit

class StepManager: ObservableObject {
    static let shared = StepManager()
    private let healthStore = HKHealthStore()
    private var observerQuery: HKObserverQuery?
    private var isInitialFetchDone = false
    
    @Published var stepCount: Int = 0
    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    
    enum AuthorizationStatus {
        case notDetermined
        case authorized
        case denied
    }
    
    init() {}
    
    func setupHealthKit() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("StepManager.setupHealthKit—HealthKit is not available on this device")
            authorizationStatus = .denied
            return
        }

        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            print("StepManager.setupHealthKit—Step count type is no longer available in HealthKit")
            authorizationStatus = .denied
            return
        }

        healthStore.getRequestStatusForAuthorization(toShare: [], read: [stepType]) { [weak self] (status, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("StepManager.setupHealthKit—Error checking authorization status: \(error.localizedDescription)")
                    self?.authorizationStatus = .notDetermined
                    return
                }

                switch status {
                    case .unnecessary:
                        self?.authorizationStatus = .authorized
                        self?.startStepCountObserver()
                    case .shouldRequest:
                        self?.requestAuthorization(for: stepType)
                    case .unknown:
                        self?.authorizationStatus = .notDetermined
                        print("StepManager.setupHealthKit—Unknown authorization status")
                    @unknown default:
                        self?.authorizationStatus = .notDetermined
                        print("StepManager.setupHealthKit—Unexpected authorization status")
                }
            }
        }
    }
    
    private func requestAuthorization(for stepType: HKQuantityType) {
        healthStore.requestAuthorization(toShare: [], read: [stepType]) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.authorizationStatus = .authorized
                    self?.startStepCountObserver()
                } else {
                    self?.authorizationStatus = .denied
                    if let error = error {
                        print("StepManager.requestAuthorization—HealthKit authorization failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func fetchTodayStepCount() {
        guard authorizationStatus == .authorized,
              let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepType,
                                          quantitySamplePredicate: predicate,
                                          options: .cumulativeSum) { [weak self] _, result, error in
                if let error = error {
                    print("StepManager.fetchTodayStepCount—Error fetching steps: \(error.localizedDescription)")
                    return
                }
                
                guard let result = result else {
                    print("StepManager.fetchTodayStepCount—No result returned")
                    return
                }
                
                if let sum = result.sumQuantity() {
                    let steps = Int(sum.doubleValue(for: .count()))
                    print("StepManager.fetchTodayStepCount—Fetched \(steps) steps")
                    DispatchQueue.main.async {
                        self?.stepCount = steps
                    }
                } else {
                    print("StepManager.fetchTodayStepCount—No steps recorded for today")
                }
            }

        healthStore.execute(query)
    }
    
    
    func startStepCountObserver() {
            guard authorizationStatus == .authorized,
                  let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
            
            // Fetch initial step count
            if !isInitialFetchDone {
                fetchTodayStepCount()
                isInitialFetchDone = true
            }

            // Set up observer query if not already set
            if observerQuery == nil {
                observerQuery = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, _, error in
                    if let error = error {
                        print("Observer query error: \(error.localizedDescription)")
                    } else {
                        self?.fetchTodayStepCount()
                    }
                }

                if let query = observerQuery {
                    healthStore.execute(query)
                    
                    healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate) { success, error in
                        if success {
                            print("Healthkit background delivery enabled")
                        } else if let error = error {
                            print("Failed to enable background delivery: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
}
