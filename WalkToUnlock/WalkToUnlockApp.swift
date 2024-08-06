import SwiftUI
import BackgroundTasks
import AuthenticationServices

@main
struct WalkToUnlockApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var stepManager = StepManager.shared
    @StateObject private var shieldManager = AppShieldManager.shared
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active && hasCompletedOnboarding {
                handleAppBecameActive()
            }
        }
        .onChange(of: hasCompletedOnboarding) { completed in
            if completed {
                scheduleStepCheckTask()
                handleAppBecameActive()
            }
        }
    }
    
    private func scheduleStepCheckTask() {
        BackgroundTaskScheduler.shared.scheduleStepCheckTask()
    }
        
    private func handleAppBecameActive() {
        Task {
            stepManager.fetchTodayStepCount()
            checkAppleIDCredentialState()
            await shieldManager.checkAndRequestAuthorization()
            await requestNotificationAuthorization()
            checkStepCountAndUpdateTasks()
        }
    }
    
    private func requestNotificationAuthorization() async {
        do {
            let granted = try await notificationManager.requestAuthorization()
            if granted {
                print("WalkToUnlockApp.requestNotificationAuthorization—Notification authorization granted")
            } else {
                print("WalkToUnlockApp.requestNotificationAuthorization—Notification authorization denied")
            }
        } catch {
            print("WalkToUnlockApp.requestNotificationAuthorization—Error requesting notification authorization: \(error)")
        }
    }
    
    private func checkStepCountAndUpdateTasks() {
        let stepThreshold = LocalStorageManager.shared.getValue(forKey: "stepThreshold", defaultValue: 0)
        
        if stepManager.stepCount > stepThreshold {
            if !shieldManager.areAppsUnblocked {
                shieldManager.clearShieldRestrictions()
            }
            
            BGTaskScheduler.shared.getPendingTaskRequests { tasks in
                let isReblockScheduled = tasks.contains { $0.identifier == AppConstants.reblockTaskIdentifier }
                
                if !isReblockScheduled {
                    BackgroundTaskScheduler.shared.scheduleReblockTask()
                    BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: AppConstants.stepCheckTaskIdentifier)
                }
            }
        } else {
            BGTaskScheduler.shared.getPendingTaskRequests { tasks in
                let isCheckStepsScheduled = tasks.contains { $0.identifier == AppConstants.stepCheckTaskIdentifier }
                
                if !isCheckStepsScheduled {
                    BackgroundTaskScheduler.shared.scheduleStepCheckTask()
                }
            }
        }
    }
    
    private func checkAppleIDCredentialState() {
        guard let userIdentifier = UserDefaults.standard.string(forKey: "AppleSignInUserID") else {
            print("WalkToUnlockApp.checkAppleIDCredentialState—No Apple User Identifier found")
            hasCompletedOnboarding = false
            return
        }

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: userIdentifier) { (credentialState, error) in
            DispatchQueue.main.async {
                switch credentialState {
                case .authorized:
                    print("WalkToUnlockApp.checkAppleIDCredentialState—Apple ID credential is valid")
                case .revoked, .notFound:
                    print("WalkToUnlockApp.checkAppleIDCredentialState—Apple ID credential is revoked or not found")
                    self.hasCompletedOnboarding = false
                default:
                    print("WalkToUnlockApp.checkAppleIDCredentialState—Unknown Apple ID credential state")
                }
            }
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("AppDelegate.application—App did finish launching.")
        registerBackgroundTasks()
        return true
    }

    private func registerBackgroundTasks() {
        print("AppDelegate.registerBackgroundTasks—Registering background tasks...")
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: AppConstants.stepCheckTaskIdentifier, using: nil) { task in
            print("AppDelegate.registerBackgroundTasks—Step check task started")
            guard let task = task as? BGAppRefreshTask else {
                print("AppDelegate.registerBackgroundTasks—Failed to cast task to BGAppRefreshTask")
                return
            }
            StepCheckTask.shared.handleStepCheckTask(task: task)
        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: AppConstants.reblockTaskIdentifier, using: nil) { task in
            print("AppDelegate.registerBackgroundTasks—Reblock task started")
            guard let task = task as? BGAppRefreshTask else {
                print("AppDelegate.registerBackgroundTasks—Failed to cast task to BGAppRefreshTask")
                return
            }
            StepCheckTask.shared.handleReblockTask(task: task)
        }
    }
}
