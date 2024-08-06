import SwiftUI

struct ChooseAppsView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var shieldManager = AppShieldManager.shared
    @State private var showingActivityPicker = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Setup WalkToUnlock")
                .font(.title3)
                .fontWeight(.medium)
            
            ProgressView(value: 3, total: 6)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(height: 2)
            
            Text("Choose apps to block")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Choose apps to block until your step threshold is reached each day. You’ll set your step threshold in the next step.")
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: displayFamilyActivityPicker) {
                Text("Choose apps")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colorScheme == .dark ? Color.white : Color.black)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .sheet(isPresented: $showingActivityPicker) {
            shieldManager.displayFamilyActivityPicker(
                title: "Select Apps",
                headerText: "Choose apps to restrict",
                footerText: "Selected apps will be restricted"
            )
            .onDisappear {
                shieldManager.setActivitySelection(shieldManager.activitySelection)
                shieldManager.setShieldRestrictions()
                print("Picker dismissed. Number of selected apps: \(shieldManager.activitySelection.applicationTokens.count)")
                viewModel.nextStep()
            }
        }
    }
    
    private func displayFamilyActivityPicker() {
        Task {
            do {
                showingActivityPicker = true;
            }
        }
    }
}

#Preview {
    ChooseAppsView()
}
