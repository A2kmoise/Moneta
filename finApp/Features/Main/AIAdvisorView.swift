import SwiftUI
import UIKit

// Assuming FintrackTheme and associated colors are defined elsewhere

// MARK: - Core View
struct AIAdvisorView: View {
    @StateObject private var viewModel = AIAdvisorViewModel()
    @State private var inputMessage: String = ""
    
    private let tips: [AITip] = [
        .init(icon: "dollarsign.circle.fill", text: "Move $50 to savings every payday.", action: "Automate"),
        .init(icon: "speedometer", text: "Set a dining cap of $180 this month.", action: "Set Limit"),
        .init(icon: "bell.badge.fill", text: "Review recurring subscriptions quarterly.", action: "Review Now")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // 1. Scrollable Chat/Tips Area
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        advisorHeader
                        tipsCarousel
                        conversationThread
                    }
                    .padding(.horizontal, FintrackUI.screenPadding)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                }
                // FIX: Updated to the modern iOS 17+ onChange syntax (zero-parameter closure)
                .onChange(of: viewModel.messages.count) {
                    // Scroll to the latest message when a new one is added
                    withAnimation {
                        proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                }
            }
            
            // 2. Chat Input Bar (Sticky to bottom)
            chatInputBar
        }
        .background(FintrackTheme.background.ignoresSafeArea())
        .navigationTitle("Moneta AI")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sendMessage() {
        guard !inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let messageText = inputMessage
        inputMessage = ""
        viewModel.sendMessage(messageText)
    }
}

// MARK: - Components
private extension AIAdvisorView {
    
    // Simplified, more impactful header
    var advisorHeader: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title)
                .foregroundColor(FintrackTheme.primaryGreen)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Moneta AI Assistant")
                    .font(.headline)
                    .foregroundColor(FintrackTheme.textPrimary)
                
                Text("Your personalized financial analyst, providing tailored advice and alerts based on your real-time data.")
                    .font(.subheadline)
                    .foregroundColor(FintrackTheme.textSecondary)
            }
        }
        .padding(FintrackUI.screenPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fintrackCardBackground(cornerRadius: FintrackUI.cardCornerRadius)
    }
    
    var tipsCarousel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Actionable Recommendations")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(FintrackTheme.textPrimary)
                .padding(.leading, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(tips) { tip in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: tip.icon)
                                    .foregroundColor(FintrackTheme.primaryGreen)
                                    .font(.title2)
                                Spacer()
                            }
                            
                            Text(tip.text)
                                .font(.footnote.weight(.medium))
                                .foregroundColor(FintrackTheme.textPrimary)
                                .frame(height: 40, alignment: .topLeading) // Ensures consistent height
                            
                            Button(action: {
                                // Send tip action to chat
                                viewModel.sendMessage(tip.action + " tip: " + tip.text)
                            }) {
                                Text(tip.action)
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(FintrackTheme.primaryGreen)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                        }
                        .padding()
                        .frame(width: 180, alignment: .leading)
                        .fintrackCardBackground(cornerRadius: FintrackUI.cardCornerRadius)
                    }
                }
            }
        }
    }

    var conversationThread: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Conversation")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(FintrackTheme.textPrimary)
                .padding(.leading, 4)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }

            VStack(spacing: 12) {
                ForEach(viewModel.messages) { message in
                    HStack {
                        if message.role == .assistant { bubble(for: message) }
                        Spacer(minLength: 12)
                        if message.role == .user { bubble(for: message) }
                    }
                    .id(message.id) // Needed for ScrollViewReader
                }
            }
        }
    }

    private func bubble(for message: AIMessage) -> some View {
        Text(message.text)
            .font(.callout) // Slightly larger font for readability
            .foregroundColor(message.role == .assistant ? FintrackTheme.textPrimary : .black)
            .padding(12)
            .background(
                message.role == .assistant ? FintrackTheme.cardBackground : FintrackTheme.primaryGreen
            )
            // Conditional corner radius based on sender
            .cornerRadius(16, corners: message.role == .assistant ? [.topRight, .bottomLeft, .bottomRight] : [.topLeft, .bottomLeft, .bottomRight])
            // Explicitly align the text inside the limited frame
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.role == .assistant ? .leading : .trailing)
    }
    
    var chatInputBar: some View {
        VStack(spacing: 8) {
            // Typing Indicator
            if viewModel.isTyping {
                HStack(spacing: 6) {
                    Circle().fill(FintrackTheme.primaryGreen).frame(width: 6, height: 6)
                    Circle().fill(FintrackTheme.primaryGreen).frame(width: 6, height: 6).offset(y: -1)
                    Circle().fill(FintrackTheme.primaryGreen).frame(width: 6, height: 6).offset(y: -2)
                    Text("Moneta AI is responding...")
                        .font(.caption2)
                        .foregroundColor(FintrackTheme.textSecondary)
                    Spacer()
                }
                .padding(.horizontal, FintrackUI.screenPadding)
            }
            
            HStack {
                TextField("Ask Moneta AI about your finances...", text: $inputMessage)
                    .foregroundColor(FintrackTheme.textPrimary)
                    .padding(.horizontal)
                    .frame(height: 50)
                    .fintrackCardBackground(cornerRadius: FintrackUI.controlCornerRadius)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(FintrackTheme.primaryGreen)
                }
                .disabled(inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, FintrackUI.screenPadding)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}

// MARK: - Data Models and Extensions
private struct AITip: Identifiable {
    let id = UUID()
    let icon: String
    let text: String
    let action: String
}

// Custom corner radius modifier for chat bubbles
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    NavigationStack {
        AIAdvisorView()
    }
}
