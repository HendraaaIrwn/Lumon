import SwiftUI

private enum CorrectAnswerPhase: CaseIterable {
    case idle
    case bounce
    case settle
}

struct CorrectAnswerAnimation: ViewModifier {
    let trigger: UUID?
    let isEnabled: Bool

    func body(content: Content) -> some View {
        if isEnabled {
            content.phaseAnimator(CorrectAnswerPhase.allCases, trigger: trigger) { view, phase in
                view
                    .scaleEffect(phase == .bounce ? 1.08 : 1)
                    .shadow(
                        color: .white.opacity(phase == .bounce ? 0.8 : 0),
                        radius: 12
                    )
            } animation: { phase in
                phase == .bounce
                    ? .spring(duration: 0.28, bounce: 0.4)
                    : .easeOut(duration: 0.16)
            }
        } else {
            content
        }
    }
}
