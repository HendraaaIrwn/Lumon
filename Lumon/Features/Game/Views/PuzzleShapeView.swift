import SwiftUI

struct PuzzleShapeView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let shape: PuzzleShape
    let isSelected: Bool
    let onSelect: () -> Void

    private var renderer: LumonShape {
        LumonShape(type: shape.type, points: shape.points, rotation: shape.rotation)
    }

    private var accessibilityDescription: String {
        var parts = [shape.type.rawValue.capitalized, shape.id]
        parts.append(isSelected ? "Selected" : "Not selected")
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
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: isSelected)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
