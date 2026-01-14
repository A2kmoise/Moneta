import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Binding var showSignUp: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                AuthHeader(title: "Sign up!", subtitle: nil)

                VStack(spacing: 20) {
                    inputFields

                    AuthErrorMessage(message: authViewModel.errorMessage)

                    AuthPrimaryButton(title: "Create account", action: authViewModel.signUp, isLoading: authViewModel.isLoading)

                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .font(.footnote)
                            .foregroundColor(FintrackTheme.textSecondary)
                        Button(action: { showSignUp = false }) {
                            Text("Sign in")
                                .font(.footnote)
                                .foregroundColor(FintrackTheme.primaryGreen)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 48)
            .padding(.bottom, 32)
        }
        .background(FintrackTheme.background.ignoresSafeArea())
    }

    private var inputFields: some View {
        VStack(spacing: 16) {
            AuthField(label: "Full name*") {
                TextField("Enter your full name", text: $authViewModel.fullName)
                    .textInputAutocapitalization(.words)
            }

            AuthField(label: "E-mail") {
                TextField("Enter your email", text: $authViewModel.signUpEmail)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }

            AuthField(label: "Password") {
                SecureField("Enter your password", text: $authViewModel.signUpPassword)
            }

            AuthField(label: "Phone number") {
                TextField("+1 000 000 0000", text: $authViewModel.phoneNumber)
                    .keyboardType(.phonePad)
            }
        }
    }
}

#Preview {
    SignUpView(showSignUp: .constant(true))
        .environmentObject(AuthViewModel())
}
