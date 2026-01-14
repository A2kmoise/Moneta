import Foundation
import SwiftUI

@MainActor
class AIAdvisorViewModel: ObservableObject {
    @Published var messages: [AIMessage] = []
    @Published var isTyping: Bool = false
    @Published var errorMessage: String?
    
    private let aiAPI = AIAPI()
    
    init() {
        // Add welcome message
        messages.append(AIMessage(
            role: .assistant,
            text: "Hello! I'm Moneta AI. I've analyzed your recent spending and I'm here to help you with personalized financial advice. Ask me anything about your finances!"
        ))
    }
    
    func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Add user message
        let userMessage = AIMessage(role: .user, text: text)
        messages.append(userMessage)
        
        // Show typing indicator
        isTyping = true
        errorMessage = nil
        
        Task {
            do {
                let reply = try await aiAPI.sendMessage(text)
                
                await MainActor.run {
                    isTyping = false
                    messages.append(AIMessage(role: .assistant, text: reply))
                }
            } catch {
                await MainActor.run {
                    isTyping = false
                    errorMessage = "Failed to get response. Please try again."
                    print("AI API error: \(error)")
                }
            }
        }
    }
}

struct AIMessage: Identifiable {
    enum Role {
        case assistant, user
    }
    
    let id = UUID()
    let role: Role
    let text: String
}
