import SwiftUI

struct SignInView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Binding var showSignUp: Bool
    // State variable to toggle password visibility
    @State private var isPasswordVisible: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                AuthHeader(title: "Welcome back!", subtitle: nil)

                VStack(spacing: 20) {
                    inputFields
                    rememberMeAndForgot

                    AuthErrorMessage(message: authViewModel.errorMessage)

                    AuthPrimaryButton(title: "Sign in", action: authViewModel.signIn, isLoading: authViewModel.isLoading)

                    bottomLink
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
            AuthField(label: "E-mail") {
                TextField("Enter your email", text: $authViewModel.signInEmail)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }

            AuthField(label: "Password") {
                HStack {
                    // Conditional rendering for SecureField vs TextField
                    if isPasswordVisible {
                        TextField("Enter your password", text: $authViewModel.signInPassword)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                    } else {
                        SecureField("Enter your password", text: $authViewModel.signInPassword)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                    }
                    
                    // Button to toggle password visibility
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                            .foregroundColor(FintrackTheme.textSecondary)
                    }
                }
            }
        }
    }

    private var rememberMeAndForgot: some View {
        HStack {
            // Checkbox-style Button
            Button(action: {
                authViewModel.rememberMe.toggle()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: authViewModel.rememberMe ? "checkmark.square.fill" : "square")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(authViewModel.rememberMe ? FintrackTheme.primaryGreen : FintrackTheme.textSecondary)
                    
                    Text("Remember Me")
                        .font(.footnote)
                        .foregroundColor(FintrackTheme.textSecondary)
                }
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

            Button(action: {
                // backend: trigger password reset flow
            }) {
                Text("Forgot Password?")
                    .font(.footnote)
                    .foregroundColor(FintrackTheme.primaryGreen)
            }
        }
    }

    private var bottomLink: some View {
        HStack(spacing: 4) {
            Text("or")
                .font(.footnote)
                .foregroundColor(FintrackTheme.textSecondary)
            Button(action: { showSignUp = true }) {
                Text("Create account")
                    .font(.footnote)
                    .foregroundColor(FintrackTheme.primaryGreen)
            }
        }
        .padding(.top, 8)
    }
}

#Preview {
    SignInView(showSignUp: .constant(false))
        .environmentObject(AuthViewModel())
}
