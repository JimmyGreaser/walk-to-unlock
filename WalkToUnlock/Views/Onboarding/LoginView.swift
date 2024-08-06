import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: OnboardingViewModel
    @StateObject private var storageManager = LocalStorageManager.shared
    @State private var authenticationCompleted = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Login to WalkToUnlock")
                .font(.title)
                .fontWeight(.bold)
            
            SignInWithAppleButton(
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        print("Authorization successful.")
                        // Here you would typically send the authorization to your server
                        handleAuthorizationSuccess(authResults)
                    case .failure(let error):
                        print("Authorization failed: " + error.localizedDescription)
                    }
                }
            )
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .frame(height: 50)
        }
        .padding()
        .onChange(of: authenticationCompleted) { completed in
            if completed {
                viewModel.nextStep()
            }
        }
    }
    
    func handleAuthorizationSuccess(_ authResults: ASAuthorization) {
        switch authResults.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                let userIdentifier = appleIDCredential.user
                print("User ID: \(userIdentifier)")
                storageManager.setValue(userIdentifier, forKey: "AppleSignInUserID")
            
                if let fullName = appleIDCredential.fullName {
                    let firstName = fullName.givenName ?? ""
                    let lastName = fullName.familyName ?? ""
                    print("Full name: \(firstName) \(lastName)")
                    storageManager.setValue(firstName, forKey: "AppleSignInFirstName")
                    storageManager.setValue(lastName, forKey: "AppleSignInFamilyName")
                }
            
                if let email = appleIDCredential.email {
                    print("Email: \(email)")
                    storageManager.setValue(email, forKey: "AppleSignInEmail")
                }
                
                authenticationCompleted = true
                
            default:
                break
        }
    }
}

#Preview("Light Mode") {
    LoginView()
        .environmentObject(OnboardingViewModel())
}

#Preview("Dark Mode") {
    LoginView()
        .environmentObject(OnboardingViewModel())
        .preferredColorScheme(.dark)
}
