import SwiftUI

// MARK: - Shimmer Modifier

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            Color.white.opacity(0.15),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 0.6)
                    .offset(x: -geometry.size.width * 0.6 + phase * geometry.size.width * 1.6)
                }
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

// MARK: - Skeleton View

struct SkeletonView: View {
    let height: CGFloat
    let cornerRadius: CGFloat

    init(height: CGFloat = 60, cornerRadius: CGFloat = AppSpacing.cornerRadius) {
        self.height = height
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(AppColors.surfaceSecondary)
            .frame(height: height)
            .modifier(ShimmerModifier())
    }
}

// MARK: - View Extensions

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }

    func cardStyle() -> some View {
        self
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge))
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}
