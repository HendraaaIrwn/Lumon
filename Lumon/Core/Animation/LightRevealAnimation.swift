import SwiftUI

private enum LightRevealPhase: CaseIterable {
    case idle
    case glow
    case confirm
}

struct LightRevealAnimation: ViewModifier {
    let trigger: UUID?
    let isEnabled: Bool

    func body(content: Content) -> some View {
        if isEnabled {
            content.phaseAnimator(LightRevealPhase.allCases, trigger: trigger) { view, phase in
                view
                    .scaleEffect(phase == .glow ? 1.12 : 1)
                    .shadow(
                        color: .white.opacity(phase == .idle ? 0 : 0.95),
                        radius: phase == .glow ? 22 : 8
                    )
            } animation: { phase in
                switch phase {
                case .idle: .easeOut(duration: 0.18)
                case .glow: .easeInOut(duration: 0.32)
                case .confirm: .spring(duration: 0.35, bounce: 0.35)
                }
            }
        } else {
            content
        }
    }
}
