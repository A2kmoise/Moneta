import SwiftUI

struct AddIncomeView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var amount = ""
    @State private var date = Date()
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let transactionAPI = TransactionAPI()

    // Convert amount string to Double
    private var amountAsDouble: Double? {
        let normalized = amount
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }

    // Check if the input is valid
    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && amountAsDouble != nil
    }

    // Format amount as currency
    private var formattedAmount: String {
        guard let value = amountAsDouble else { return "—" }
        return value.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }

    // Format date as string
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: 6) {
                            // Income title
                            Text(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "New Income" : title)
                                .font(.headline)
                                .lineLimit(1)
                                .foregroundColor(FintrackTheme.textPrimary)

                            // Income details
                            HStack(spacing: 8) {
                                Label("Income", systemImage: "arrow.down.circle.fill")
                                    .labelStyle(.titleAndIcon)
                                    .font(.subheadline)
                                    .foregroundColor(FintrackTheme.textSecondary)

                                Text("•")
                                    .foregroundColor(FintrackTheme.textSecondary)

                                Label(formattedDate, systemImage: "calendar")
                                    .labelStyle(.titleAndIcon)
                                    .font(.subheadline)
                                    .foregroundColor(FintrackTheme.textSecondary)
                            }
                        }

                        Spacer(minLength: 12)

                        // Formatted amount
                        Text(formattedAmount)
                            .font(.title3.weight(.semibold))
                            .monospacedDigit()
                            .foregroundColor(FintrackTheme.textPrimary)
                    }
                    .padding(.vertical, 6)
                }

                Section("Details") {
                    // Source / Title
                    HStack(spacing: 10) {
                        Image(systemName: "textformat")
                            .foregroundColor(FintrackTheme.textSecondary)
                        TextField("Source", text: $title)
                            .textInputAutocapitalization(.words)
                            .submitLabel(.next)
                            .foregroundColor(FintrackTheme.textPrimary)
                    }

                    // Amount input
                    HStack(spacing: 10) {
                        Image(systemName: "dollarsign.circle")
                            .foregroundColor(FintrackTheme.primaryGreen)
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(FintrackTheme.textPrimary)
                    }

                    // Invalid number warning
                    if !amount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && amountAsDouble == nil {
                        Text("Enter a valid number (e.g. 12.50)")
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    // Date picker
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Add Income")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(FintrackTheme.background.ignoresSafeArea())
            .tint(FintrackTheme.primaryGreen)
            .fintrackGlassNavigationBar()
            .onAppear {
                UITableView.appearance().backgroundColor = .clear
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(FintrackTheme.textPrimary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        saveIncome()
                    } label: {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Text("Save")
                        }
                    }
                    .disabled(!isValid || isLoading)
                    .foregroundColor(isValid && !isLoading ? FintrackTheme.primaryGreen : FintrackTheme.textSecondary)
                }
            }
        }
    }
    
    private func saveIncome() {
        guard let amountValue = amountAsDouble else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                _ = try await transactionAPI.createIncome(
                    category: title.isEmpty ? "other" : title.lowercased(),
                    amount: amountValue,
                    date: date
                )
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to save: \(error.localizedDescription)"
                }
            }
        }
    }
}
