import SwiftUI

struct PuzzleShapeView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let shape: PuzzleShape
    let isSelected: Bool
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
        if isSelected, !shape.clues.isEmpty {
            let clueNames = shape.clues.map(\.color.accessibilityName).joined(separator: ", ")
            parts.append("Clues: \(clueNames)")
        }
        return parts.joined(separator: ". ")
    }

    var body: some View {
        Button(action: onSelect) {
            ZStack {
                renderer
                    .fill(shape.color?.swiftUIColor ?? .black)

                renderer
                    .stroke(
                        isSelected ? Color.white : Color.clear,
                        style: StrokeStyle(lineWidth: 4, lineJoin: .round)
                    )

                renderer
                    .stroke(
                        isSelected ? Color.accentColor : Color.clear,
                        style: StrokeStyle(lineWidth: 2, lineJoin: .round)
                    )

                if isSelected, !shape.clues.isEmpty {
                    ClueDotsView(clues: shape.clues)
                        .padding(12)
                        .allowsHitTesting(false)
                }
            }
            .contentShape(.interaction, renderer)
        }
        .buttonStyle(.plain)
        .modifier(LightRevealAnimation(trigger: revealTrigger, isEnabled: !reduceMotion))
        .modifier(CorrectAnswerAnimation(trigger: correctTrigger, isEnabled: !reduceMotion))
        .modifier(WrongAnswerAnimation(trigger: wrongTrigger, isEnabled: !reduceMotion))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: isSelected)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
