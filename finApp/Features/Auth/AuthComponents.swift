import SwiftUI

struct AuthHeader: View {
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 8) {
                Text("Moneta")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(FintrackTheme.primaryGreen)
            }

            VStack(spacing: 8) {
                Text(title)
                    .fintrackTitleStyle()
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .fintrackSubtitleStyle()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct AuthField<Content: View>: View {
    let label: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(FintrackTheme.textSecondary)

            content()
                .padding()
                .background(FintrackTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.08))
                )
                .cornerRadius(12)
                .foregroundColor(FintrackTheme.textPrimary)
        }
    }
}

struct AuthPrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false

    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        .scaleEffect(0.8)
                }
                Text(title)
                    .font(.headline)
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isLoading ? FintrackTheme.primaryGreen.opacity(0.6) : FintrackTheme.primaryGreen)
            .cornerRadius(12)
        }
        .disabled(isLoading)
    }
}

struct AuthErrorMessage: View {
    let message: String?

    var body: some View {
        if let message {
            Text(message)
                .font(.footnote)
                .foregroundColor(.red)
        }
    }
}

struct AuthInfoMessage: View {
    let message: String?

    var body: some View {
        if let message {
            Text(message)
                .font(.footnote)
                .foregroundColor(FintrackTheme.primaryGreen)
        }
    }
}

struct AuthFooterLink: View {
    let leadingText: String
    let actionText: String
    let action: () -> Void

    var body: some View {
        HStack {
            Text(leadingText)
                .font(.footnote)
                .foregroundColor(FintrackTheme.textSecondary)

            Button(action: action) {
                Text(actionText)
                    .font(.footnote)
                    .foregroundColor(FintrackTheme.primaryGreen)
            }
        }
        .padding(.top, 8)
    }
}
