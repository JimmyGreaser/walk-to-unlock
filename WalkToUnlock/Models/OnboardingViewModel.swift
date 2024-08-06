import Foundation

class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .login
    @Published var isOnboardingComplete = false
    
    func nextStep() {
        if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            currentStep = nextStep
        }
    }
    
    func completeOnboarding() {
        isOnboardingComplete = true
    }
}

enum OnboardingStep: Int, CaseIterable {
    case login
    case healthKitAccess
    case screenTimeAccess
    case chooseApps
    case setStepThreshold
    case allowNotifications
}
