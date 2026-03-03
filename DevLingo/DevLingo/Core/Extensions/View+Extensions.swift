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

// MARK: - Press Animation Modifier

struct PressAnimationModifier: ViewModifier {
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
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

    func pressAnimation() -> some View {
        modifier(PressAnimationModifier())
    }
}
