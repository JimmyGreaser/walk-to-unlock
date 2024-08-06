import SwiftUI
import FamilyControls

struct FamilyActivityPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var activitySelection: FamilyActivitySelection

    let title: String
    let headerText: String
    let footerText: String

    var body: some View {
        NavigationView {
            VStack {
                FamilyActivityPicker(headerText: headerText,
                                     footerText: footerText,
                                     selection: $activitySelection)
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                    
                }
            )
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    @State var previewSelection = FamilyActivitySelection()
    return FamilyActivityPickerView(
        activitySelection: $previewSelection,
        title: "Select Apps",
        headerText: "Choose apps to restrict",
        footerText: "Selected apps will be restricted"
    )
}
