import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        VStack {
            switch viewModel.currentStep {
                case .login:
                    LoginView()
                        .environmentObject(viewModel)
                case .healthKitAccess:
                    HealthKitAccessView()
                        .environmentObject(viewModel)
                case .screenTimeAccess:
                    ScreenTimeAccessView()
                        .environmentObject(viewModel)
                case .chooseApps:
                    ChooseAppsView()
                        .environmentObject(viewModel)
                case .setStepThreshold:
                    SetStepThresholdView()
                        .environmentObject(viewModel)
                case .allowNotifications:
                    AllowNotificationsView()
                        .environmentObject(viewModel)
            }
        }
        .animation(.easeInOut, value: viewModel.currentStep)
        .onChange(of: viewModel.isOnboardingComplete) { completed in
            if completed {
                hasCompletedOnboarding = true
            }
        }
    }
}
