import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var amount = ""
    @State private var category: TransactionCategory = .food
    @State private var date = Date()
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let transactionAPI = TransactionAPI()

    // MARK: - Amount Parsing (NaN-safe)
    private var amountAsDouble: Double? {
        let normalized = amount
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        guard let value = Double(normalized), value.isFinite else {
            return nil
        }
        return value
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        amountAsDouble != nil
    }

    // MARK: - Formatting
    private var formattedAmount: String {
        guard let value = amountAsDouble else { return "—" }
        return value.formatted(
            .currency(code: Locale.current.currency?.identifier ?? "USD")
        )
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    // MARK: - View
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Header
                Section {
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(
                                title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? "New Expense"
                                : title
                            )
                            .font(.headline)
                            .lineLimit(1)
                            .foregroundColor(FintrackTheme.textPrimary)

                            HStack(spacing: 8) {
                                Label(category.title, systemImage: "tag.fill")
                                    .font(.subheadline)
                                    .foregroundColor(FintrackTheme.textSecondary)

                                Text("•")
                                    .foregroundColor(FintrackTheme.textSecondary)

                                Label(formattedDate, systemImage: "calendar")
                                    .font(.subheadline)
                                    .foregroundColor(FintrackTheme.textSecondary)
                            }
                        }

                        Spacer(minLength: 12)

                        Text(formattedAmount)
                            .font(.title3.weight(.semibold))
                            .monospacedDigit()
                            .foregroundColor(FintrackTheme.textPrimary)
                    }
                    .padding(.vertical, 6)
                }

                // MARK: - Details
                Section("Details") {
                    // Title
                    HStack(spacing: 10) {
                        Image(systemName: "textformat")
                            .foregroundColor(FintrackTheme.textSecondary)

                        TextField("Title", text: $title)
                            .textInputAutocapitalization(.words)
                            .submitLabel(.next)
                            .foregroundColor(FintrackTheme.textPrimary)
                    }

                    // Amount
                    HStack(spacing: 10) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(FintrackTheme.primaryGreen)

                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(FintrackTheme.textPrimary)
                    }

                    if !amount.isEmpty && amountAsDouble == nil {
                        Text("Enter a valid number (e.g. 12.50)")
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    // Category
                    Picker("Category", selection: $category) {
                        ForEach(TransactionCategory.allCases, id: \.self) {
                            Text($0.title)
                        }
                    }

                    // Date (ONLY ONE DATE PICKER)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Add Expense")
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
                        saveExpense()
                    } label: {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Text("Save")
                        }
                    }
                    .disabled(!isValid || isLoading)
                    .foregroundColor(
                        isValid && !isLoading
                        ? FintrackTheme.primaryGreen
                        : FintrackTheme.textSecondary
                    )
                }
            }
        }
    }
    
    private func saveExpense() {
        guard let amountValue = amountAsDouble else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                _ = try await transactionAPI.createExpense(
                    category: category.rawValue,
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
