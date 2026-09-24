import SwiftUI

struct PuzzleShapeView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    let shape: PuzzleShape
    let isSelected: Bool
    let areCluesVisible: Bool
    let isEnabled: Bool
    let isTutorialTarget: Bool
    let feedbackEvent: GameFeedbackEvent?
    let onSelect: () -> Void

    private var targetedEvent: GameFeedbackEvent? {
        feedbackEvent?.shapeID == shape.id ? feedbackEvent : nil
    }

    private var revealTrigger: UUID? {
        switch targetedEvent?.kind {
        case .hint, .completedByHint: targetedEvent?.id
        default: nil
        }
    }

    private var wrongTrigger: UUID? {
        targetedEvent?.kind == .incorrect ? targetedEvent?.id : nil
    }

    private var correctTrigger: UUID? {
        switch targetedEvent?.kind {
        case .correct, .completed: targetedEvent?.id
        default: nil
        }
    }

    private var renderer: LumonShape {
        LumonShape(type: shape.type, points: shape.points, rotation: shape.rotation)
    }

    private var accessibilityDescription: String {
        var parts = [shape.type.rawValue.capitalized, shape.id]
        parts.append(isSelected ? "Selected" : "Not selected")
        if let color = shape.color {
            parts.append("\(color.accessibilityName). Locked")
        } else {
            parts.append("Unrevealed")
        }
        if areCluesVisible, !shape.clues.isEmpty {
            let clueNames = shape.clues.map(\.color.accessibilityName).joined(separator: ", ")
            parts.append("Clues: \(clueNames)")
        }
        return parts.joined(separator: ". ")
    }

    var body: some View {
        Button(action: onSelect) {
            ZStack {
                renderer
                    .fill(shape.color?.swiftUIColor ?? LumonPalette.cream)

                renderer
                    .stroke(
                        isSelected ? (shape.color == nil ? LumonPalette.ink : LumonPalette.cream) : Color.clear,
                        style: StrokeStyle(lineWidth: LumonStroke.medium, lineJoin: .round)
                    )

                renderer
                    .stroke(
                        isTutorialTarget ? LumonPalette.orange : Color.clear,
                        style: StrokeStyle(lineWidth: LumonStroke.thin, lineJoin: .round)
                    )

                if areCluesVisible, !shape.clues.isEmpty {
                    ClueDotsView(
                        clues: shape.clues,
                        shape: renderer,
                        differentiateWithoutColor: differentiateWithoutColor
                    )
                    .transition(
                        reduceMotion
                            ? .opacity
                            : .scale(scale: 0.7).combined(with: .opacity)
                    )
                        .allowsHitTesting(false)
                }
            }
            .contentShape(.interaction, renderer)
            .shadow(
                color: isTutorialTarget ? LumonPalette.orange.opacity(0.62) : .clear,
                radius: isTutorialTarget ? 8 : 0
            )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled || isTutorialTarget || shape.color != nil ? 1 : 0.35)
        .modifier(LightRevealAnimation(trigger: revealTrigger, isEnabled: !reduceMotion))
        .modifier(CorrectAnswerAnimation(trigger: correctTrigger, isEnabled: !reduceMotion))
        .modifier(WrongAnswerAnimation(trigger: wrongTrigger, isEnabled: !reduceMotion))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: isSelected)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.22), value: areCluesVisible)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: isTutorialTarget)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
