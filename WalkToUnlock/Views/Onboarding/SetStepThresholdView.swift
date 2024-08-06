import SwiftUI

struct SetStepThresholdView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var storeManager = LocalStorageManager.shared
    @State private var stepThreshold: Int = 5000
    @State private var stepThresholdString: String = "5000"
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Setup WalkToUnlock")
                .font(.title3)
                .fontWeight(.medium)
            
            ProgressView(value: 4, total: 6)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(height: 2)
            
            Text("Set step threshold")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Set a number of steps that must be exceeded before your apps are unblocked.")
                .foregroundColor(.secondary)
            
            Spacer()
            
            TextField("Enter step threshold", text: $stepThresholdString)
                .font(.system(size: 18))
                .padding()
                .frame(height: 50)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .keyboardType(.numberPad)
                .onChange(of: stepThresholdString) { newValue in
                    if let number = Int(newValue), number > 0 {
                        stepThreshold = number
                    }
                }
            
            Spacer()
            
            Button(action: saveStepThreshold) {
                Text("Save")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colorScheme == .dark ? Color.white : Color.black)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .onTapGesture {
            isInputFocused = false
        }
    }
    
    private func saveStepThreshold() {
        isInputFocused = false
        storeManager.setValue(stepThreshold, forKey: "stepThreshold")
        viewModel.nextStep()
    }
}

#Preview {
    SetStepThresholdView()
}
