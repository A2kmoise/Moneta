import SwiftUI
import UIKit

extension View {
    func fintrackGlassNavigationBar() -> some View {
        self
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                let standard = UINavigationBarAppearance()
                standard.configureWithDefaultBackground()
                standard.backgroundEffect = UIBlurEffect(style: .systemChromeMaterial)
                standard.backgroundColor = .clear
                standard.shadowColor = .clear
                standard.titleTextAttributes = [.foregroundColor: UIColor.label]
                standard.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

                let scrollEdge = UINavigationBarAppearance()
                scrollEdge.configureWithTransparentBackground()
                scrollEdge.shadowColor = .clear
                scrollEdge.titleTextAttributes = [.foregroundColor: UIColor.label]
                scrollEdge.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

                let appearance = UINavigationBar.appearance()
                appearance.standardAppearance = standard
                appearance.compactAppearance = standard
                appearance.scrollEdgeAppearance = scrollEdge
            }
    }

    func fintrackSolidNavigationBar(background: Color = FintrackTheme.primaryGreen) -> some View {
        self
            .toolbarBackground(background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .tint(.white)
    }
}
