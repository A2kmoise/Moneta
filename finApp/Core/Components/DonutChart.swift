import SwiftUI

struct DonutChart: View {
    let percentage: Double
    let label: String
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    FintrackTheme.textSecondary.opacity(0.2),
                    lineWidth: 10
                )
            
            Circle()
                .trim(from: 0, to: percentage / 100)
                .stroke(
                    FintrackTheme.primaryGreen,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            VStack(spacing: 2) {
                Text("\(Int(percentage))%")
                    .font(.caption.bold())
                    .foregroundColor(FintrackTheme.textPrimary)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(FintrackTheme.textSecondary)
            }
        }
        .frame(width: 70, height: 70)
    }
}
