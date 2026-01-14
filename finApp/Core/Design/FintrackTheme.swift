import SwiftUI

enum FintrackTheme {
    static let primaryGreen = Color(red: 0.58, green: 0.99, blue: 0.25) // adjust as needed
    static let background = Color(.systemBackground)
    static let cardBackground = Color(.secondarySystemBackground)
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
}

extension Text {
    func fintrackTitleStyle() -> some View {
        self
            .font(.title2.weight(.semibold))
            .foregroundColor(FintrackTheme.textPrimary)
    }

    func fintrackSubtitleStyle() -> some View {
        self
            .font(.subheadline)
            .foregroundColor(FintrackTheme.textSecondary)
    }
}
