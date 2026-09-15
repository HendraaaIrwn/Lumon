import SwiftUI

private enum WrongAnswerPhase: CaseIterable {
    case idle
    case left
    case right
    case settle
}

struct WrongAnswerAnimation: ViewModifier {
    let trigger: UUID?
    let isEnabled: Bool

    func body(content: Content) -> some View {
        if isEnabled {
            content.phaseAnimator(WrongAnswerPhase.allCases, trigger: trigger) { view, phase in
                view
                    .offset(x: offset(for: phase))
                    .shadow(
                        color: .red.opacity(phase == .idle || phase == .settle ? 0 : 0.9),
                        radius: 10
                    )
            } animation: { _ in
                .easeInOut(duration: 0.09)
            }
        } else {
            content
        }
    }

    private func offset(for phase: WrongAnswerPhase) -> CGFloat {
        switch phase {
        case .idle, .settle: 0
        case .left: -8
        case .right: 8
        }
    }
}
