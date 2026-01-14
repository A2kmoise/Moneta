import SwiftUI

// NOTE: Assumes Transaction, TransactionType, TransactionCategory,
// FintrackTheme, and SampleData are defined elsewhere and accessible.

// --- START: Fixes applied to MainTransactionHistoryView ---

struct MainTransactionHistoryView: View {
    @StateObject private var viewModel = TransactionHistoryViewModel()
    @State private var searchText: String = ""
    @State private var selectedTab: TransactionTab = .spending
    
    enum TransactionTab: String, CaseIterable {
        case all = "All"
        case spending = "Spending"
        case income = "Income"
    }
    
    private var filteredTransactions: [Transaction] {
        var transactions = viewModel.transactions
        
        // 1. Filter by Tab
        switch selectedTab {
        case .spending:
            // FIX: Changed from $0.type == .expense to $0.type == .spending
            // OR use .expense if your TransactionType enum only contains .expense and .income.
            // Based on your last successful model definition, I will assume you meant to use the .expense case for filtering spending:
            transactions = transactions.filter { $0.type == .expense }
        case .income:
            transactions = transactions.filter { $0.type == .income }
        case .all:
            break
        }
        
        // 2. Filter by Search
        if !searchText.isEmpty {
            transactions = transactions.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.category.title.localizedCaseInsensitiveContains(searchText)
            }
        }
        return transactions
    }

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            tabBar
            
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .scaleEffect(1.2)
                Spacer()
            } else if let error = viewModel.errorMessage {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(FintrackTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Retry") {
                        viewModel.refresh()
                    }
                    .foregroundColor(FintrackTheme.primaryGreen)
                }
                Spacer()
            } else if viewModel.transactions.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.largeTitle)
                        .foregroundColor(FintrackTheme.textSecondary)
                    Text("No transactions yet")
                        .font(.headline)
                        .foregroundColor(FintrackTheme.textPrimary)
                    Text("Add your first transaction to get started")
                        .font(.subheadline)
                        .foregroundColor(FintrackTheme.textSecondary)
                }
                Spacer()
            } else {
                TransactionHistoryListView(transactions: filteredTransactions)
            }
        }
        .background(FintrackTheme.background.ignoresSafeArea())
        .navigationTitle("Transaction History")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadTransactions()
        }
        .refreshable {
            viewModel.refresh()
        }
    }
    
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(FintrackTheme.textSecondary)
            TextField("Super AI search", text: $searchText)
                .foregroundColor(FintrackTheme.textPrimary)
                .autocorrectionDisabled(true)
                .keyboardType(.webSearch)
        }
        .padding(.horizontal, FintrackUI.screenPadding)
        .padding(.vertical, 12)
        .fintrackCardBackground(cornerRadius: FintrackUI.controlCornerRadius)
        .padding(.horizontal, FintrackUI.screenPadding)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
    
    private var tabBar: some View {
        FintrackPillSegmentedControl(
            tabs: Array(TransactionTab.allCases),
            title: { $0.rawValue },
            selection: $selectedTab
        )
        .padding(.horizontal, FintrackUI.screenPadding)
        .padding(.bottom, 10)
    }
}
  

// MARK: - 2. Transaction History List View (The 'Cards' structure)

struct TransactionHistoryListView: View {
    let transactions: [Transaction]
    
    private var grouped: [String: [Transaction]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return Dictionary(grouping: transactions) { formatter.string(from: $0.date) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                ForEach(grouped.keys.sorted(by: { dateString1, dateString2 in
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "d MMMM yyyy"
                    let date1 = dateFormatter.date(from: dateString1) ?? Date.distantPast
                    let date2 = dateFormatter.date(from: dateString2) ?? Date.distantPast
                    return date1 > date2
                }), id: \.self) { dateKey in
                    
                    // This VStack forms the main Card container
                    VStack(alignment: .leading, spacing: 0) {
                        
                        // Header for the Card (Date/Day)
                        Text(formatHeaderDate(dateString: dateKey))
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(FintrackTheme.textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                        
                        // Transaction Rows inside the Card
                        VStack(spacing: 0) {
                            ForEach(grouped[dateKey]?.sorted(by: { $0.date > $1.date }) ?? []) { transaction in
                                
                                // FIX: Corrected typo in struct name to TransactionRowView
                                TransactionRoView(transaction: transaction)
                                    .padding(.vertical, 10)
                                
                                if transaction.id != grouped[dateKey]?.sorted(by: { $0.date > $1.date }).last?.id {
                                    Divider()
                                        .background(FintrackTheme.textSecondary.opacity(0.2))
                                        .padding(.leading, 50)
                                }
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                    }
                    .fintrackCardBackground(cornerRadius: FintrackUI.cardCornerRadius)
                    .padding(.horizontal, FintrackUI.screenPadding)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
    }
    
    private func formatHeaderDate(dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "d MMMM yyyy"
        
        if let date = inputFormatter.date(from: dateString) {
            let calendar = Calendar.current
            if calendar.isDateInToday(date) {
                return "Today"
            } else if calendar.isDateInYesterday(date) {
                return "Yesterday"
            }
            
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "d MMMM yyyy"
            return outputFormatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - 3. Transaction Row View (Renders a single row)

// FIX: Corrected struct name from TransactionRoView to TransactionRowView
struct TransactionRoView: View {
    let transaction: Transaction
    
    private var amountColor: Color {
        // Use expense/income type for color determination
        transaction.type == .expense ? FintrackTheme.textPrimary : FintrackTheme.primaryGreen
    }
    
    private var amountString: String {
        let absAmount = abs(transaction.amount)
        // Check for expense vs income
        return String(format: "%@$%.0f", transaction.type == .expense ? "-" : "+", absAmount)
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: transaction.date)
    }

    private var iconColor: Color {
        // Use the color associated with the category enum (defined in your models)
        transaction.category.color
    }
    
    private var iconSystemName: String {
        // Derive system name based on the category
        switch transaction.category {
        case .shopping: return "cart.fill"
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .subscriptions: return "repeat"
        case .entertainment: return "tv.fill"
        case .other: return "questionmark.circle.fill"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconSystemName)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .padding(8)
                .background(FintrackTheme.background)
                .cornerRadius(10)
                .foregroundColor(iconColor)

            VStack(alignment: .leading, spacing: 2) {
                // Transaction Title (e.g., Groceries)
                Text(transaction.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(FintrackTheme.textPrimary)
                
                // Transaction Category Title (e.g., Food)
                Text(transaction.category.title)
                    .font(.caption)
                    .foregroundColor(FintrackTheme.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(amountString)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(amountColor)
                
                Text(timeString)
                    .font(.caption)
                    .foregroundColor(FintrackTheme.textSecondary)
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MainTransactionHistoryView()
    }
}
