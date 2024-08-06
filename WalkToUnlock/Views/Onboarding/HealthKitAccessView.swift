//import SwiftUI
//import FamilyControls
//
//struct HealthKitAccessView: View {
//    @EnvironmentObject var viewModel: OnboardingViewModel
//    @Environment(\.colorScheme) var colorScheme
//    @StateObject private var stepManager = StepManager.shared
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 20) {
//            Text("Setup WalkToUnlock")
//                .font(.title3)
//                .fontWeight(.medium)
//            
//            ProgressView(value: 1, total: 6)
//                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
//                .frame(height: 2)
//            
//            Text("Allow Health Kit Access")
//                .font(.title)
//                .fontWeight(.bold)
//            
//            Text("Health Kit is used so your step count can be monitored.")
//                .foregroundColor(.secondary)
//            
//            Spacer()
//            
//            Button(action: requestAuthorization) {
//                Text(stepManager.authorizationStatus == .denied ? "Retry Health Kit Access" : "Allow Health Kit Access")
//                    .fontWeight(.semibold)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(colorScheme == .dark ? Color.white : Color.black)
//                    .foregroundColor(colorScheme == .dark ? .black : .white)
//                    .cornerRadius(10)
//            }
//            .disabled(!stepManager.canRequestAuthorization)
//
//            if stepManager.authorizationStatus == .denied {
//                Text("Health Kit access was denied. Please try again or enable it in Settings.")
//                    .foregroundColor(.red)
//                    .font(.caption)
//            }
//        }
//        .padding()
////        .onChange(of: stepManager.authorizationStatus) { newStatus in
////            if newStatus == .authorized {
////                viewModel.nextStep()
////            }
////        }
//        .onChange(of: stepManager.authorizationStatus) { newStatus in
//            if newStatus == .authorized {
//                viewModel.nextStep()
//            } else if newStatus == .denied {
//                print("Health Kit access was denied. Please enable it in Settings.")
//            }
//        }
//        .onAppear {
//            stepManager.checkStepCountAuthorizationStatus()
//        }
//    }
//    
//    private func requestAuthorization() {
//        stepManager.requestAuthorization()
//    }
//}

import SwiftUI
import HealthKit

struct HealthKitAccessView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var stepManager = StepManager.shared
    @State private var showingSettingsAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Setup WalkToUnlock")
                .font(.title3)
                .fontWeight(.medium)

            ProgressView(value: 1, total: 6)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(height: 2)

            Text("Allow Health Kit Access")
                .font(.title)
                .fontWeight(.bold)

            Text("Health Kit is used so your step count can be monitored.")
                .foregroundColor(.secondary)

            Spacer()

            Button(action: requestAuthorization) {
                Text("Allow Health Kit Access")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colorScheme == .dark ? Color.white : Color.black)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .onChange(of: stepManager.authorizationStatus) { newStatus in
            viewModel.nextStep()
        }
    }
    
    private func requestAuthorization() {
//        stepManager.requestAuthorization()
        stepManager.setupHealthKit()

    }
}

struct HealthKitAccessView_Previews: PreviewProvider {
    static var previews: some View {
        HealthKitAccessView()
            .environmentObject(OnboardingViewModel())
    }
}
