import SwiftUI

struct SetStepThresholdPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var stepThresholdString: String = ""
    @AppStorage("stepThreshold") var stepThreshold: Int = 5000

    var body: some View {
        NavigationView {
            VStack {
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
            }
            .padding()
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    if let number = Int(stepThresholdString), number > 0 {
                        stepThreshold = number
                    }
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .navigationTitle("Set step threshold")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            stepThresholdString = String(stepThreshold)
        }
    }
}

#Preview {
    SetStepThresholdPickerView()
}
