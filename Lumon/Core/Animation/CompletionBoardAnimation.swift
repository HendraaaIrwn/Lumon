import SwiftUI

private enum CompletionBoardPhase: CaseIterable {
    case idle
    case glow
    case settle
}

struct CompletionBoardAnimation: ViewModifier {
    let trigger: UUID?
    let isEnabled: Bool

    func body(content: Content) -> some View {
        if isEnabled {
            content.phaseAnimator(CompletionBoardPhase.allCases, trigger: trigger) { view, phase in
                view
                    .scaleEffect(phase == .glow ? 1.025 : 1)
                    .shadow(
                        color: Color.yellow.opacity(phase == .idle ? 0 : 0.42),
                        radius: phase == .glow ? 28 : 8
                    )
            } animation: { phase in
                phase == .glow ? .spring(duration: 0.42, bounce: 0.24) : .easeOut(duration: 0.28)
            }
        } else {
            content
        }
    }
}
