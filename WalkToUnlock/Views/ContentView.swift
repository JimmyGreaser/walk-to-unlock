import SwiftUI
import FamilyControls
import BackgroundTasks

struct ContentView: View {
    @StateObject private var storageManager = LocalStorageManager.shared
    @StateObject private var stepManager = StepManager.shared
    @StateObject private var shieldManager = AppShieldManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
    @AppStorage("stepThreshold") private var stepThreshold: Int = 0
    @AppStorage("AppleSignInFirstName") private var firstName: String = ""
    
    @State private var stepThresholdString: String = ""
    @State private var showingActivityPicker = false
    @State private var showingStepThresholdPicker = false
    @State private var requiresHealthKitAccess = false

    var body: some View {
            VStack(alignment: .leading, spacing: 40) {
                
                VStack(alignment: .leading, spacing: 8) {
                    if firstName == "" {
                        Text("\(TimeHelper.getGreeting())!")
                            .font(.title)
                            .fontWeight(.bold)
                    } else {
                        Text("\(TimeHelper.getGreeting()), \(firstName)!")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    
                    if stepManager.stepCount < stepThreshold {
                        Text("Keep walking to unblock your apps.")
                            .foregroundColor(.secondary)
                    } else {
                        Text("You’re reached your step count for the day. Your apps will be blocked again at 4am tomorrow.")
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack() {
                        Text("Step threshold")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                        Button("Edit") {
                            showingStepThresholdPicker = true
                        }
                    }
                    
                    if stepThreshold > 0 {
                        let progress = min(Double(stepManager.stepCount) / Double(stepThreshold), 1.0)
                        VStack(alignment: .leading, spacing: 4) {
                            ProgressView(value: progress)
                                .accentColor(progress >= 1.0 ? .green : .blue)
                            Text("\(stepManager.stepCount) / \(stepThreshold) steps")
                                .font(.caption)
                        }
                    } else {
                        Text("Set a step threshold to see progress")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack() {
                        Text("\(shieldManager.areAppsUnblocked ? "Unblocked" : "Blocked") apps")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                        Button("Edit") {
                            showingActivityPicker = true
                        }
                    }
                    if shieldManager.equatableActivitySelection.selection.applicationTokens.isEmpty &&
                        shieldManager.equatableActivitySelection.selection.categoryTokens.isEmpty &&
                        shieldManager.equatableActivitySelection.selection.webDomainTokens.isEmpty {
                        Text("No apps, categories, or domains selected")
                            .foregroundColor(.secondary)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            if !shieldManager.equatableActivitySelection.selection.applicationTokens.isEmpty {
                                ForEach(Array(shieldManager.equatableActivitySelection.selection.applicationTokens), id: \.self) { token in
                                    Label(token)
                                        .font(.subheadline)
                                        .labelStyle(.titleAndIcon)
                                }
                            }
                            
                            if !shieldManager.equatableActivitySelection.selection.categoryTokens.isEmpty {
                                ForEach(Array(shieldManager.equatableActivitySelection.selection.categoryTokens), id: \.self) { token in
                                    Label(token)
                                        .font(.subheadline)
                                        .labelStyle(.titleAndIcon)
                                }
                            }
                            
                            if !shieldManager.equatableActivitySelection.selection.webDomainTokens.isEmpty {
                                ForEach(Array(shieldManager.equatableActivitySelection.selection.webDomainTokens), id: \.self) { token in
                                    Label(token)
                                        .font(.subheadline)
                                        .labelStyle(.titleAndIcon)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            stepManager.setupHealthKit()
            stepThresholdString = "\(stepThreshold)"
        }
        .sheet(isPresented: $showingActivityPicker) {
            shieldManager.displayFamilyActivityPicker(
                title: "Select Apps",
                headerText: "Choose apps to restrict",
                footerText: "Selected apps will be restricted"
            )
            .onDisappear {
                shieldManager.setActivitySelection(shieldManager.activitySelection)
                if stepManager.stepCount < stepThreshold {
                    print("Setting shield restrictions")
                    shieldManager.setShieldRestrictions()
                }
                print("ContentView—Picker dismissed. Number of selected apps: \(shieldManager.activitySelection.applicationTokens.count)")
            }
        }
        .sheet(isPresented: $showingStepThresholdPicker) {
            SetStepThresholdPickerView()
            .onDisappear {
                if stepManager.stepCount < stepThreshold {
                    print("Setting shield restrictions")
                    shieldManager.setShieldRestrictions()
                } else {
                    print("Clearing shield restrictions")
                    shieldManager.clearShieldRestrictions()
                }
            }
        }
    }
}

extension StepManager.AuthorizationStatus: CustomStringConvertible {
    var description: String {
        switch self {
        case .notDetermined: return "Not Determined"
        case .authorized: return "Authorized"
        case .denied: return "Denied"
        }
    }
}
