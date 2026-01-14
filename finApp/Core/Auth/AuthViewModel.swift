import SwiftUI

final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false

    // Sign in fields
    @Published var signInEmail: String = ""
    @Published var signInPassword: String = ""
    @Published var rememberMe: Bool = false

    // Sign up fields
    @Published var fullName: String = ""
    @Published var signUpEmail: String = ""
    @Published var signUpPassword: String = ""
    @Published var phoneNumber: String = ""
    
    // Current user profile
    @Published var currentUserName: String = ""
    @Published var currentUserEmail: String = ""

    // Forgot password
    @Published var resetEmail: String = ""

    // Simple error message placeholder
    @Published var errorMessage: String? = nil
    @Published var statusMessage: String? = nil

    private let authAPI = AuthAPI()
    private var budgetViewModel: BudgetViewModel?

    init() {
        isAuthenticated = TokenStore.shared.token != nil
        if isAuthenticated {
            Task { await refreshSession() }
        }
    }
    
    func setBudgetViewModel(_ budgetViewModel: BudgetViewModel) {
        self.budgetViewModel = budgetViewModel
        if isAuthenticated {
            Task { @MainActor in
                budgetViewModel.loadBudgets()
                budgetViewModel.loadBudgetSummary()
            }
        }
    }

    @MainActor
    private func refreshSession() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let profile = try await authAPI.me()
            currentUserName = profile.fullName
            currentUserEmail = profile.email
            isAuthenticated = true
            
            // Load budgets after successful session refresh
            budgetViewModel?.loadBudgets()
            budgetViewModel?.loadBudgetSummary()
        } catch {
            authAPI.logout()
            isAuthenticated = false
        }
    }

    func signIn() {
        // backend: replace with API call and token/session handling
        errorMessage = nil
        statusMessage = nil
        guard !signInEmail.isEmpty, !signInPassword.isEmpty else {
            errorMessage = "Please enter email and password."
            return
        }

        isLoading = true
        Task { @MainActor in
            defer { isLoading = false }
            do {
                _ = try await authAPI.login(email: signInEmail, password: signInPassword)
                let profile = try await authAPI.me()
                currentUserName = profile.fullName
                currentUserEmail = profile.email
                isAuthenticated = true
                
                // Load budgets after successful login
                budgetViewModel?.loadBudgets()
                budgetViewModel?.loadBudgetSummary()
            } catch {
                isAuthenticated = false
                errorMessage = Self.userFacingErrorMessage(from: error)
            }
        }
    }

    func signUp() {
        // backend: replace with API call to create account then store session
        errorMessage = nil
        statusMessage = nil
        guard !fullName.isEmpty, !signUpEmail.isEmpty, !signUpPassword.isEmpty else {
            errorMessage = "Please fill all required fields."
            return
        }

        isLoading = true
        Task { @MainActor in
            defer { isLoading = false }
            do {
                _ = try await authAPI.register(
                    fullName: fullName,
                    email: signUpEmail,
                    phoneNumber: phoneNumber,
                    password: signUpPassword
                )
                let profile = try await authAPI.me()
                currentUserName = profile.fullName
                currentUserEmail = profile.email
                isAuthenticated = true
                
                // Load budgets after successful registration
                budgetViewModel?.loadBudgets()
                budgetViewModel?.loadBudgetSummary()
            } catch {
                isAuthenticated = false
                errorMessage = Self.userFacingErrorMessage(from: error)
            }
        }
    }

    func signOut() {
        authAPI.logout()
        currentUserName = ""
        currentUserEmail = ""
        isAuthenticated = false
    }
    
    @MainActor
    func updateProfile(fullName: String?, currentPassword: String?, password: String?) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await authAPI.updateProfile(fullName: fullName, currentPassword: currentPassword, password: password)
            
            // Refresh profile data after update
            let profile = try await authAPI.me()
            currentUserName = profile.fullName
            currentUserEmail = profile.email
            
            statusMessage = "Profile updated successfully"
        } catch {
            errorMessage = Self.userFacingErrorMessage(from: error)
            throw error
        }
    }

    func sendPasswordReset() {
        // backend: call password reset endpoint; handle success/error states
        errorMessage = nil
        statusMessage = nil

        guard !resetEmail.isEmpty else {
            errorMessage = "Please enter your email."
            return
        }

        statusMessage = "Reset link sent to \(resetEmail)."
    }

    private static func userFacingErrorMessage(from error: Error) -> String {
        if let apiError = error as? APIClientError {
            switch apiError {
            case .httpError(_, let message):
                return message ?? "Request failed."
            default:
                return "Request failed."
            }
        }

        return "Something went wrong."
    }
}
