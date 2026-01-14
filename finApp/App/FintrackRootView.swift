import SwiftUI

/// Root view you should use in your App entry:
/// WindowGroup { FintrackRootView() }
struct FintrackRootView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("appColorScheme") private var appColorScheme: AppColorScheme = .system

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingFlowView(hasCompletedOnboarding: $hasCompletedOnboarding)
            } else {
                AuthContainerView()
                    .environmentObject(authViewModel)
            }
        }
        .preferredColorScheme(appColorScheme.preferredColorScheme)
    }
}

#Preview {
    FintrackRootView()
}
