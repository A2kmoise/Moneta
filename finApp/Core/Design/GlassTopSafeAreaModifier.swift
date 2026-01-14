import SwiftUI
import UIKit

private enum SafeAreaInsetReader {
    static func top() -> CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
        let window = windowScene?.windows.first { $0.isKeyWindow }
        return window?.safeAreaInsets.top ?? 0
    }
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {
    func fintrackGlassTopSafeArea(
        scrollOffset: CGFloat,
        threshold: CGFloat = -1,
        visibleOpacity: CGFloat = 0.95
    ) -> some View {
        self
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(height: SafeAreaInsetReader.top())
                    .opacity(scrollOffset < threshold ? visibleOpacity : 0)
                    .animation(
                        .easeInOut(duration: 0.18),
                        value: scrollOffset < threshold
                    )
                    .allowsHitTesting(false)
                    .ignoresSafeArea(edges: .top)
            }
    }

    func fintrackTrackScrollOffset(in coordinateSpace: String, onChange: @escaping (CGFloat) -> Void) -> some View {
        self
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: proxy.frame(in: .named(coordinateSpace)).minY
                        )
                }
            )
            .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: onChange)
    }
}
