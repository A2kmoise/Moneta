import SwiftUI

struct OnboardingPageInfo: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let showsDot: Bool
}

struct OnboardingFlowView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentIndex = 0

    private let pages: [OnboardingPageInfo] = [
        OnboardingPageInfo(
            title: "Take Control of Your Finances",
            subtitle: "Track expenses, set budgets, and stay in control of your money every single day.",
            showsDot: false
        ),
        OnboardingPageInfo(
            title: "Budget Smarter",
            subtitle: "Understand where your money goes and build better financial habits effortlessly.",
            showsDot: true
        ),
        OnboardingPageInfo(
            title: "All Your Money. One Place.",
            subtitle: "Link your accounts, cards, and wallets to get a complete view of your finances.",
            showsDot: true
        )
    ]

    var body: some View {
        ZStack {
            FintrackTheme.background
                .ignoresSafeArea()

            VStack {
                Spacer(minLength: 60)

                // Hero brand section
                heroBrandSection

                Spacer()

                // Onboarding text
                onboardingTextSection

                Spacer()

                // Action buttons
                actionButtons
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Hero Brand

    private var heroBrandSection: some View {
        VStack(spacing: 12) {
            Text("MONETA")
                .font(.system(size: 46, weight: .bold, design: .rounded))
                .foregroundColor(FintrackTheme.primaryGreen)
                .tracking(1.8)

            if pages[currentIndex].showsDot {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [FintrackTheme.primaryGreen, .orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 80, height: 80)
                    .padding(.top, 8)
            }
        }
    }

    // MARK: - Onboarding Text

    private var onboardingTextSection: some View {
        VStack(spacing: 16) {
            Text(pages[currentIndex].title)
                .fintrackTitleStyle()
                .multilineTextAlignment(.center)

            Text(pages[currentIndex].subtitle)
                .fintrackSubtitleStyle()
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
        }
    }

    // MARK: - Actions

    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button(action: primaryAction) {
                Text(primaryButtonTitle)
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(FintrackTheme.primaryGreen)
                    .cornerRadius(14)
            }

            Button {
                hasCompletedOnboarding = true
            } label: {
                Text("Skip")
                    .font(.subheadline)
                    .foregroundColor(FintrackTheme.textSecondary)
            }
        }
        .padding(.bottom, 40)
    }

    // MARK: - Logic

    private var primaryButtonTitle: String {
        currentIndex < pages.count - 1 ? "Next" : "Get Started"
    }

    private func primaryAction() {
        withAnimation(.easeInOut) {
            if currentIndex < pages.count - 1 {
                currentIndex += 1
            } else {
                hasCompletedOnboarding = true
            }
        }
    }
}

#Preview {
    OnboardingFlowView(hasCompletedOnboarding: .constant(false))
}
