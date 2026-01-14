import SwiftUI

enum FintrackUI {
    static let screenPadding: CGFloat = 16
    static let cardCornerRadius: CGFloat = 16
    static let cardCornerRadiusLarge: CGFloat = 20
    static let controlCornerRadius: CGFloat = 14
}

extension View {
    func fintrackCard(cornerRadius: CGFloat = FintrackUI.cardCornerRadius) -> some View {
        self
            .padding(FintrackUI.screenPadding)
            .background(FintrackTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(.primary.opacity(0.06), lineWidth: 1)
            }
    }

    func fintrackCardBackground(cornerRadius: CGFloat = FintrackUI.cardCornerRadius) -> some View {
        self
            .background(FintrackTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(.primary.opacity(0.06), lineWidth: 1)
            }
    }
}

struct FintrackPillSegmentedControl<T: Hashable & CaseIterable>: View where T.AllCases: RandomAccessCollection {
    let tabs: [T]
    let title: (T) -> String
    @Binding var selection: T

    var body: some View {
        HStack(spacing: 6) {
            ForEach(tabs, id: \.self) { tab in
                Button {
                    selection = tab
                } label: {
                    Text(title(tab))
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(selection == tab ? .black : FintrackTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: FintrackUI.controlCornerRadius, style: .continuous)
                                .fill(selection == tab ? FintrackTheme.primaryGreen : FintrackTheme.cardBackground)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: FintrackUI.cardCornerRadius, style: .continuous)
                .fill(FintrackTheme.cardBackground)
        )
        .overlay {
            RoundedRectangle(cornerRadius: FintrackUI.cardCornerRadius, style: .continuous)
                .strokeBorder(.primary.opacity(0.06), lineWidth: 1)
        }
    }
}
