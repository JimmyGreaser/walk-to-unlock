import SwiftUI
import FamilyControls

struct ScreenTimeAccessView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var shieldManager = AppShieldManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Setup WalkToUnlock")
                .font(.title3)
                .fontWeight(.medium)
            
            ProgressView(value: 2, total: 6)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(height: 2)
            
            Text("Allow Screen Time Access")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Screen Time is used so you can choose apps to block until you exceed your step count every day.")
                .foregroundColor(.secondary)
            
            Text("You'll choose the apps to block and set your step count in the next steps.")
                .foregroundColor(.secondary)
            
            Text("Your data is completely private and never leaves your device.")
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: requestAuthorization) {
                Text("Allow Screen Time Access")
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
    
    private func requestAuthorization() {
        Task {
            do {
                try await shieldManager.requestAuthorization()
                viewModel.nextStep()
            } catch {
                print("Failed to request authorization: \(error)")
                // Handle the error, maybe show an alert to the user
            }
        }
    }
}

struct ScreenTimeAccessView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenTimeAccessView()
            .environmentObject(OnboardingViewModel())
    }
}
