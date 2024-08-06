import Foundation
import BackgroundTasks
import UserNotifications

class StepCheckTask {
    static let shared = StepCheckTask()
    private init() {}

    func handleStepCheckTask(task: BGAppRefreshTask) {
        let stepManager = StepManager.shared
        let shieldManager = AppShieldManager.shared
        let storageManager = LocalStorageManager.shared
        
        let stepThreshold = storageManager.getValue(forKey: "stepThreshold", defaultValue: 0)
        
        task.expirationHandler = {
            BackgroundTaskScheduler.shared.scheduleStepCheckTask()
            task.setTaskCompleted(success: false)
        }
        
        if stepManager.stepCount >= stepThreshold {
            shieldManager.clearShieldRestrictions()
            
            NotificationManager.shared.sendNotification(
                title: "Step Goal Reached!",
                body: "Your apps are now unblocked for the day."
            )
            
            BackgroundTaskScheduler.shared.scheduleReblockTask()

            task.setTaskCompleted(success: true)
        } else {
            BackgroundTaskScheduler.shared.scheduleStepCheckTask()
            task.setTaskCompleted(success: true)
        }
    }
    
    func handleReblockTask(task: BGAppRefreshTask) {
        let shieldManager = AppShieldManager.shared
        let storageManager = LocalStorageManager.shared
        let stepThreshold = storageManager.getValue(forKey: "stepThreshold", defaultValue: 0)
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        if shieldManager.areAppsUnblocked {
            shieldManager.setShieldRestrictions()
            
            NotificationManager.shared.sendNotification(
                title: "Walk \(stepThreshold) Steps To Unblock Your Apps",
                body: "Your apps have been blocked for the day until you walk \(stepThreshold) steps."
            )
            
            BackgroundTaskScheduler.shared.scheduleStepCheckTask()
        }
        
        task.setTaskCompleted(success: true)
    }
}
