 import SwiftUI
 import UIKit


struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var budgetViewModel = BudgetViewModel()
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Namespace private var tabAnimation
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView()
                    .fintrackGlassNavigationBar()
            }
            .tabItem { TabItemLabel(text: "Home", systemImage: "house.fill") }
            .tag(0)

            NavigationStack {
                BudgetListView()
                    .fintrackGlassNavigationBar()
                    .environmentObject(budgetViewModel)
            }
            .tabItem { TabItemLabel(text: "Budgets", systemImage: "chart.bar.fill") }
            .tag(1)

            NavigationStack {
                MainTransactionHistoryView()
                    .fintrackGlassNavigationBar()
            }
            .tabItem { TabItemLabel(text: "Transactions", systemImage: "arrow.up.arrow.down.circle.fill") }
            .tag(2)

            NavigationStack {
                AIAdvisorView()
                    .fintrackGlassNavigationBar()
            }
            .tabItem { TabItemLabel(text: "Advisor", systemImage: "brain.head.profile") }
            .tag(3)

            NavigationStack {
                ProfileView()
                    .fintrackGlassNavigationBar()
            }
            .tabItem { TabItemLabel(text: "Profile", systemImage: "person.crop.circle.fill") }
            .tag(4)
        }
        .transaction { transaction in
            transaction.animation = nil
        }
        .animation(nil, value: selectedTab)
        .tint(FintrackTheme.primaryGreen)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            appearance.shadowColor = nil
            
            // Connect BudgetViewModel with AuthViewModel
            authViewModel.setBudgetViewModel(budgetViewModel)
            
            // Custom item spacing and styling
            let itemAppearance = UITabBarItemAppearance()
            itemAppearance.normal.iconColor = UIColor.systemGray
            itemAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.systemGray,
                .font: UIFont.systemFont(ofSize: 10, weight: .medium)
            ]
            itemAppearance.selected.iconColor = UIColor(FintrackTheme.primaryGreen)
            itemAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(FintrackTheme.primaryGreen),
                .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
            ]
            
            appearance.stackedLayoutAppearance = itemAppearance
            appearance.inlineLayoutAppearance = itemAppearance
            appearance.compactInlineLayoutAppearance = itemAppearance
            
            let tabBar = UITabBar.appearance()
            tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
            
            // Floating effect with shadow
            tabBar.layer.shadowColor = UIColor.black.cgColor
            tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
            tabBar.layer.shadowRadius = 8
            tabBar.layer.shadowOpacity = 0.1
            tabBar.layer.masksToBounds = false
            
            // Rounded top corners
            tabBar.layer.cornerRadius = 20
            tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
}

// --- 4. A Reusable Component for Tab Item Labels ---
// This improves readability and consistency across all tab items.

private struct TabItemLabel: View {
    let text: String
    let systemImage: String

    var body: some View {
        Label(text, systemImage: systemImage)
    }
}

// --- Preview ---

#Preview {
    MainTabView()
}
