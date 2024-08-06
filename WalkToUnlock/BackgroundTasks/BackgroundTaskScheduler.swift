import Foundation
import BackgroundTasks
import UserNotifications

class BackgroundTaskScheduler {
    static let shared = BackgroundTaskScheduler()
    private init() {}

    func scheduleStepCheckTask() {
        let request = BGAppRefreshTaskRequest(identifier: AppConstants.stepCheckTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("BackgroundTaskScheduler.scheduleStepCheckTask—Successfully scheduled step check task")
        } catch {
            print("BackgroundTaskScheduler.scheduleStepCheckTask—Could not schedule step check task: \(error)")
            if let bgError = error as? BGTaskScheduler.Error {
                switch bgError.code {
                case .unavailable:
                    print("BackgroundTaskScheduler.scheduleStepCheckTask—Background Task Scheduler is unavailable")
                case .tooManyPendingTaskRequests:
                    print("BackgroundTaskScheduler.scheduleStepCheckTask—Too many pending task requests")
                case .notPermitted:
                    print("BackgroundTaskScheduler.scheduleStepCheckTask—App is not permitted to schedule background tasks")
                @unknown default:
                    print("BackgroundTaskScheduler.scheduleStepCheckTask—Unknown BGTaskScheduler error: \(bgError.localizedDescription)")
                }
            } else {
                print("BackgroundTaskScheduler.scheduleStepCheckTask—Unexpected error type: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleReblockTask() {
        let request = BGAppRefreshTaskRequest(identifier: AppConstants.reblockTaskIdentifier)
        
        // Schedule for 4 AM tomorrow
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.day! += 1  // Next day
        components.hour = 4   // 4 AM
        components.minute = 0
        request.earliestBeginDate = calendar.date(from: components)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("BackgroundTaskScheduler.scheduleReblockTask—Successfully scheduled reblock task")
        } catch {
            print("BackgroundTaskScheduler.scheduleReblockTask—Could not schedule reblock task: \(error)")
            if let bgError = error as? BGTaskScheduler.Error {
                switch bgError.code {
                case .unavailable:
                    print("BackgroundTaskScheduler.scheduleReblockTask—Background Task Scheduler is unavailable")
                case .tooManyPendingTaskRequests:
                    print("BackgroundTaskScheduler.scheduleReblockTask—Too many pending task requests")
                case .notPermitted:
                    print("BackgroundTaskScheduler.scheduleReblockTask—App is not permitted to schedule background tasks")
                @unknown default:
                    print("BackgroundTaskScheduler.scheduleReblockTask—Unknown BGTaskScheduler error: \(bgError.localizedDescription)")
                }
            } else {
                print("BackgroundTaskScheduler.scheduleReblockTask—Unexpected error type: \(error.localizedDescription)")
            }
        }
    }
}
