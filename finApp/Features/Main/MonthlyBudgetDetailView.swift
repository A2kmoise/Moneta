import SwiftUI

struct BudgetListView: View {
    @EnvironmentObject private var viewModel: BudgetViewModel
    @State private var selectedTab: BudgetTab = .active
    @State private var isPresentingAddBudget: Bool = false
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                FintrackPillSegmentedControl(
                    tabs: Array(BudgetTab.allCases),
                    title: { $0.rawValue },
                    selection: $selectedTab
                )
                .padding(.top, 12)

                if selectedTab == .active {
                    activeBudgetsList
                } else {
                    closedBudgetsList
                }
            }
            .padding(.horizontal, FintrackUI.screenPadding)
            .padding(.bottom, 32)
            .fintrackTrackScrollOffset(in: "BudgetListScroll") { value in
                scrollOffset = value
            }
        }
        .coordinateSpace(name: "BudgetListScroll")
        .fintrackGlassTopSafeArea(scrollOffset: scrollOffset)
        .background(FintrackTheme.background.ignoresSafeArea())
        .navigationTitle("Budgets")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            viewModel.refresh()
        }
        .sheet(isPresented: $isPresentingAddBudget) {
            AddBudgetView(
                viewModel: viewModel,
                suggestedIncome: viewModel.budgetSummary?.totalIncome ?? 0
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCompactAdaptation(.popover)
            .presentationContentInteraction(.resizes)
            .presentationBackground(FintrackTheme.background)
        }
    }

    private var activeBudgetsList: some View {
        VStack(spacing: 16) {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .padding(.top, 50)
            } else {
                let activeBudgets = viewModel.budgets.filter { $0.status == .active || $0.status == .exceeded }
                
                if activeBudgets.isEmpty {
                    emptyBudgetsView(message: "No active budgets yet")
                } else {
                    ForEach(activeBudgets) { budget in
                        BudgetCardView(budget: budget, viewModel: viewModel)
                    }
                }
            }
            
            AddBudgetCardView {
                isPresentingAddBudget = true
            }
        }
    }

    private var closedBudgetsList: some View {
        VStack(spacing: 16) {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .padding(.top, 50)
            } else {
                let closedBudgets = viewModel.budgets.filter { $0.status == .completed }
                
                if closedBudgets.isEmpty {
                    emptyBudgetsView(message: "No closed budgets yet")
                } else {
                    ForEach(closedBudgets) { budget in
                        BudgetCardView(budget: budget, viewModel: viewModel)
                    }
                }
            }
        }
    }

    private func emptyBudgetsView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.largeTitle)
                .foregroundColor(FintrackTheme.textSecondary)
            Text(message)
                .font(.headline)
                .foregroundColor(FintrackTheme.textPrimary)
            if message.contains("active") {
                Text("Create your first budget to track spending")
                    .font(.subheadline)
                    .foregroundColor(FintrackTheme.textSecondary)
            }
        }
        .padding(.top, 50)
    }
}


struct AddBudgetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: BudgetViewModel
    
    let suggestedIncome: Double

    @State private var name: String = ""
    @State private var category: String = "general"
    @State private var limit: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    private var limitAsDouble: Double? {
        let normalized = limit
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && limitAsDouble != nil
    }

    private var formattedSuggestedIncome: String {
        suggestedIncome.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }

    private var formattedLimit: String {
        guard let value = limitAsDouble else { return "—" }
        return value.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "New Budget" : name)
                                .font(.headline)
                                .lineLimit(1)
                                .foregroundColor(FintrackTheme.textPrimary)

                            HStack(spacing: 8) {
                                Label("Budget", systemImage: "target")
                                    .labelStyle(.titleAndIcon)
                                    .font(.subheadline)
                                    .foregroundColor(FintrackTheme.textSecondary)

                                Text("•")
                                    .foregroundColor(FintrackTheme.textSecondary)

                                Label("Suggested income: \(formattedSuggestedIncome)", systemImage: "arrow.down.circle")
                                    .labelStyle(.titleAndIcon)
                                    .font(.subheadline)
                                    .foregroundColor(FintrackTheme.textSecondary)
                            }
                        }

                        Spacer(minLength: 12)

                        Text(formattedLimit)
                            .font(.title3.weight(.semibold))
                            .monospacedDigit()
                            .foregroundColor(FintrackTheme.textPrimary)
                    }
                    .padding(.vertical, 6)
                }

                Section("Details") {
                    HStack(spacing: 10) {
                        Image(systemName: "textformat")
                            .foregroundColor(FintrackTheme.textSecondary)
                        TextField("Budget name", text: $name)
                            .textInputAutocapitalization(.words)
                            .submitLabel(.next)
                            .foregroundColor(FintrackTheme.textPrimary)
                    }

                    HStack(spacing: 10) {
                        Image(systemName: "banknote")
                            .foregroundColor(FintrackTheme.primaryGreen)
                        TextField("Limit amount", text: $limit)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(FintrackTheme.textPrimary)
                    }

                    if !limit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && limitAsDouble == nil {
                        Text("Enter a valid number (e.g. 2500)")
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Add Budget")
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
                    Button("Save") {
                        saveBudget()
                    }
                    .disabled(!isValid || isLoading)
                    .foregroundColor(isValid && !isLoading ? FintrackTheme.primaryGreen : FintrackTheme.textSecondary)
                }
            }
        }
    }
    
    private func saveBudget() {
        guard let limitValue = limitAsDouble else { return }
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await viewModel.createBudget(
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    allocatedAmount: limitValue,
                    category: category
                )
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to create budget: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct BudgetCardView: View {
    let budget: Budget
    @ObservedObject var viewModel: BudgetViewModel
    @State private var showDeleteConfirmation = false
    @State private var showUseAmountAlert = false
    @State private var useAmount = ""
    @State private var isProcessingUse = false
    @State private var showCloseConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(budget.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(FintrackTheme.textPrimary)

                Spacer()
                
                if budget.status != .completed {
                    Button {
                        showUseAmountAlert = true
                    } label: {
                        Text("Use")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(FintrackTheme.primaryGreen)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button {
                        showCloseConfirmation = true
                    } label: {
                        Text("Close")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Button {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.red.opacity(0.8))
                }
                .buttonStyle(PlainButtonStyle())
            }

            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Monthly spending limit")
                        .font(.title3.weight(.medium))
                        .foregroundColor(FintrackTheme.textPrimary)

                    Text("Spend: $\(String(format: "%.0f", budget.spent)) / $\(String(format: "%.0f", budget.allocatedAmount))")
                        .font(.headline)
                        .foregroundColor(FintrackTheme.textSecondary)
                }

                Spacer()

                // Donut Chart
                ZStack {
                    // Background Ring (Gray)
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 20)

                    // Remaining Budget Ring (Green)
                    Circle()
                        .trim(from: 0, to: max(0.0, 1.0 - budget.progress))
                        .stroke(FintrackTheme.primaryGreen, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    // Center percentage text
                    VStack(spacing: 2) {
                        Text("\(Int(max(0.0, 1.0 - budget.progress) * 100))%")
                            .font(.title2.weight(.bold))
                            .foregroundColor(FintrackTheme.textPrimary)
                        Text("remaining")
                            .font(.caption2)
                            .foregroundColor(FintrackTheme.textSecondary)
                    }
                }
                .frame(width: 120, height: 120)
            }

            // Legend
            HStack(spacing: 16) {
                LegendItem(color: Color(red: 0.5, green: 0.8, blue: 0.2), text: "Within")
                LegendItem(color: Color.orange, text: "Risk")
                LegendItem(color: Color.blue, text: "Overspending")
            }
            .padding(.top, 10)
        }
        .fintrackCard(cornerRadius: FintrackUI.cardCornerRadiusLarge)
        .alert("Use Budget Amount", isPresented: $showUseAmountAlert) {
            TextField("Amount", text: $useAmount)
                .keyboardType(.decimalPad)
            Button("Cancel", role: .cancel) {
                useAmount = ""
            }
            Button("Use", role: .none) {
                useBudgetAmount()
            }
            .disabled(useAmount.isEmpty || isProcessingUse)
        } message: {
            Text("Enter amount spent from '\(budget.name)' budget:")
        }
        .alert("Close Budget?", isPresented: $showCloseConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Close", role: .destructive) {
                closeBudget()
            }
        } message: {
            Text("Are you sure you want to close '\(budget.name)'? This will mark it as completed.")
        }
        .alert("Delete Budget?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteBudget()
            }
        } message: {
            Text("Are you sure you want to delete '\(budget.name)'?")
        }
    }
    
    private func deleteBudget() {
        guard let budgetId = budget.id else { return }
        Task {
            do {
                try await viewModel.deleteBudget(id: budgetId)
            } catch {
                print("Failed to delete budget: \(error)")
            }
        }
    }
    
    private func closeBudget() {
        guard let budgetId = budget.id else { return }
        Task {
            do {
                try await viewModel.closeBudget(id: budgetId)
            } catch {
                print("Failed to close budget: \(error)")
            }
        }
    }
    
    private func useBudgetAmount() {
        guard let amount = Double(useAmount), amount > 0, let budgetId = budget.id else { return }
        
        isProcessingUse = true
        
        Task {
            do {
                // Use the budget endpoint to track spending
                try await viewModel.useBudget(id: budgetId, amount: amount)
                
                await MainActor.run {
                    useAmount = ""
                    isProcessingUse = false
                }
            } catch {
                await MainActor.run {
                    isProcessingUse = false
                    print("Failed to use budget: \(error)")
                }
            }
        }
    }
}

struct LegendItem: View {
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
                .font(.caption2)
                .foregroundColor(FintrackTheme.textSecondary)
        }
    }
}

struct AddBudgetCardView: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            onTap()
        }) {
            VStack {
                Image(systemName: "plus.circle.dashed")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(FintrackTheme.textSecondary)
                Text("Add new budget")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(FintrackTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .fintrackCardBackground(cornerRadius: FintrackUI.cardCornerRadiusLarge)
            .overlay {
                RoundedRectangle(cornerRadius: FintrackUI.cardCornerRadiusLarge, style: .continuous)
                    .stroke(FintrackTheme.textSecondary.opacity(0.35), style: StrokeStyle(lineWidth: 1, dash: [6]))
            }
        }
    }
}

enum BudgetTab: String, CaseIterable {
    case active = "Active"
    case closed = "Closed"
}

#Preview {
    NavigationStack {
        BudgetListView()
    }
}
