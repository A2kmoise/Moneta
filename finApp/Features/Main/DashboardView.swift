import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var selectedTab: TransactionTab = .all
    @State private var addAction: AddAction?

    enum TransactionTab: String, CaseIterable {
        case all = "All"
        case spending = "Spending"
        case income = "Income"
    }

    enum AddAction: Identifiable {
        case income
        case expense
        var id: Int { hashValue }
    }

    private var filteredTransactions: [Transaction] {
        switch selectedTab {
        case .all:
            viewModel.recentTransactions
        case .spending:
            viewModel.recentTransactions.filter { $0.type == .expense }
        case .income:
            viewModel.recentTransactions.filter { $0.type == .income }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                header
                balanceCard
                accountsSection
                quickActions
                recentActivity
            }
            .padding(.horizontal, FintrackUI.screenPadding)
            .padding(.bottom, 32)
        }
        .background(FintrackTheme.background.ignoresSafeArea())
        .navigationTitle("Overview")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadDashboard()
        }
        .refreshable {
            viewModel.refresh()
        }
        .sheet(item: $addAction) { action in
            Group {
                switch action {
                case .expense:
                    AddExpenseView()
                case .income:
                    AddIncomeView()
                }
            }
            .presentationBackground(FintrackTheme.background)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCompactAdaptation(.popover)
            .presentationContentInteraction(.resizes)
            .onDisappear {
                viewModel.refresh()
            }
        }
    }
}

// Header
private extension DashboardView {
    var header: some View {
        HStack {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            }
            Text("Hi, \(authViewModel.fullName.split(separator: " ").first ?? "User") 👋")
                .font(.title2.weight(.bold))
                .foregroundColor(FintrackTheme.textPrimary)
            Spacer()
        }
        .padding(.top, 12)
    }
}

// Balance
private extension DashboardView {
    var balanceCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Total Balance")
                .font(.callout)
                .foregroundColor(FintrackTheme.textSecondary)

            Text(String(format: "$%.2f", viewModel.balance))
                .font(.largeTitle.bold())
                .foregroundColor(FintrackTheme.primaryGreen)

            HStack {
                Text("You spent \(Int(viewModel.spendingPercentage))% of your income this month")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(FintrackTheme.textPrimary)

                Spacer()
                
                DonutChart(
                    percentage: max(0, min(100, 100 - viewModel.spendingPercentage)),
                    label: "Saved"
                )
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .fintrackCard(cornerRadius: FintrackUI.cardCornerRadiusLarge)
    }
}

// Accounts
private extension DashboardView {
    var accountsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Accounts")
                .font(.headline.bold())
                .foregroundColor(FintrackTheme.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    DashboardStatCardView(
                        title: "Income",
                        amount: viewModel.totalIncome,
                        icon: AnyView(
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                        )
                    )

                    DashboardStatCardView(
                        title: "Expenses",
                        amount: viewModel.totalExpenses,
                        icon: AnyView(
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                        )
                    )

                    DashboardStatCardView(
                        title: "Balance",
                        amount: viewModel.balance,
                        icon: AnyView(
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.down")
                                Image(systemName: "arrow.up")
                            }
                            .font(.title3.weight(.semibold))
                            .foregroundColor(FintrackTheme.primaryGreen)
                        )
                    )
                }
            }
        }
    }
}

// Quick Actions
private extension DashboardView {
    var quickActions: some View {
        HStack {
            NavigationLink(destination: MainTransactionHistoryView()) {
                actionButton("arrow.up.circle", "Expense")
            }
            .buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: MainTransactionHistoryView()) {
                actionButton("chart.line.uptrend.xyaxis", "Income")
            }
            .buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: MainTransactionHistoryView()) {
                actionButton("creditcard", "Balance")
            }
            .buttonStyle(PlainButtonStyle())

            Menu {
                Button {
                    addAction = .expense
                } label: {
                    Label("Add Expense", systemImage: "arrow.up.circle")
                }

                Button {
                    addAction = .income
                } label: {
                    Label("Add Income", systemImage: "arrow.down.circle")
                }
            } label: {
                actionButton("plus.circle.fill", "Add", primary: true)
            }
        }
    }

    func actionButton(_ icon: String, _ title: String, primary: Bool = false) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(primary ? .black : FintrackTheme.primaryGreen)
                .frame(width: 48, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(primary ? FintrackTheme.primaryGreen : FintrackTheme.cardBackground)
                )

            Text(title)
                .font(.caption2)
                .foregroundColor(FintrackTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// Recent Activity
private extension DashboardView {
    var recentActivity: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline.bold())
                .foregroundColor(FintrackTheme.textPrimary)

            HStack {
                ForEach(TransactionTab.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        VStack(spacing: 6) {
                            Text(tab.rawValue)
                                .font(.subheadline.bold())
                                .foregroundColor(
                                    selectedTab == tab
                                    ? FintrackTheme.primaryGreen
                                    : FintrackTheme.textSecondary
                                )

                            Rectangle()
                                .fill(
                                    selectedTab == tab
                                    ? FintrackTheme.primaryGreen
                                    : .clear
                                )
                                .frame(height: 2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            if filteredTransactions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.largeTitle)
                        .foregroundColor(FintrackTheme.textSecondary)
                    Text("No transactions yet")
                        .font(.subheadline)
                        .foregroundColor(FintrackTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .fintrackCardBackground(cornerRadius: FintrackUI.cardCornerRadius)
            } else {
                VStack(spacing: 0) {
                    ForEach(filteredTransactions.prefix(5)) { transaction in
                        TransactionRowView(transaction: transaction)

                        if transaction.id != filteredTransactions.prefix(5).last?.id {
                            Divider()
                                .opacity(0.15)
                                .padding(.leading, 56)
                        }
                    }
                }
                .fintrackCardBackground(cornerRadius: FintrackUI.cardCornerRadius)
            }
        }
    }
}

// Account Card
struct AccountCardView: View {
    let account: Account

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: account.iconName)
                .font(.title2)
                .foregroundColor(FintrackTheme.primaryGreen)

            Text(String(format: "$%.2f", account.balance))
                .font(.headline.bold())
                .foregroundColor(FintrackTheme.textPrimary)

            Text(account.title)
                .font(.caption)
                .foregroundColor(FintrackTheme.textSecondary)
        }
        .padding(FintrackUI.screenPadding)
        .frame(width: 140, height: 150)
        .fintrackCardBackground(cornerRadius: FintrackUI.cardCornerRadiusLarge)
    }
}

struct DashboardStatCardView: View {
    let title: String
    let amount: Double
    let icon: AnyView

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            icon

            Text(Self.compactCurrency(amount))
                .font(.title3.bold())
                .foregroundColor(FintrackTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .monospacedDigit()

            Text(title)
                .font(.caption)
                .foregroundColor(FintrackTheme.textSecondary)
        }
        .padding(16)
        .frame(width: 130, height: 120)
        .fintrackCardBackground(cornerRadius: FintrackUI.cardCornerRadiusLarge)
    }

    private static func compactCurrency(_ value: Double) -> String {
        let absValue = abs(value)
        let sign = value < 0 ? "-" : ""
        let symbol = Locale.current.currencySymbol ?? "$"

        if absValue >= 1_000_000 {
            return "\(sign)\(symbol)\(String(format: "%.1f", absValue / 1_000_000))M"
        }
        if absValue >= 1_000 {
            return "\(sign)\(symbol)\(String(format: "%.1f", absValue / 1_000))K"
        }
        return "\(sign)\(symbol)\(String(format: "%.2f", absValue))"
    }
}

// Transaction Row
struct TransactionRowView: View {
    let transaction: Transaction

    private var icon: String {
        switch transaction.category {
        case .shopping: "bag.fill"
        case .food: "fork.knife"
        case .transport: "car.fill"
        case .subscriptions: "repeat"
        case .entertainment: "tv.fill"
        case .other: "questionmark.circle.fill"
        }
    }

    private var amount: String {
        let sign = transaction.type == .expense ? "-" : "+"
        return "\(sign)$\(String(format: "%.2f", abs(transaction.amount)))"
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 36, height: 36)
                .background(transaction.category.color.opacity(0.2))
                .cornerRadius(10)
                .foregroundColor(transaction.category.color)

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.subheadline.bold())
                    .foregroundColor(FintrackTheme.textPrimary)

                Text(transaction.category.title)
                    .font(.caption)
                    .foregroundColor(FintrackTheme.textSecondary)
            }

            Spacer()

            Text(amount)
                .font(.subheadline.bold())
                .foregroundColor(
                    transaction.type == .income
                    ? FintrackTheme.primaryGreen
                    : FintrackTheme.textPrimary
                )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    DashboardView()
}
