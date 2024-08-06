import SwiftUI

struct AllowNotificationsView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var stepThreshold: Int = 0
    @State private var stepThresholdString: String = "5000"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Setup WalkToUnlock")
                .font(.title3)
                .fontWeight(.medium)
            
            ProgressView(value: 5, total: 6)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(height: 2)
            
            Text("Allow notifications")
                .font(.title)
                .fontWeight(.bold)
            
            Text("You’ll only be notified when your apps are unblocked when you reach your step count for the day.")
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: allowNotifications) {
                Text("Allow notifications")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colorScheme == .dark ? Color.white : Color.black)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    private func allowNotifications() {
        Task {
            do {
                let status = try await notificationManager.requestAuthorization()
                print("Notification status: \(status)")
                if status {
                    viewModel.completeOnboarding()
                } else {
                    print("Need notification permissions")
                }
            }
        }
    }
}

#Preview {
    AllowNotificationsView()
}
