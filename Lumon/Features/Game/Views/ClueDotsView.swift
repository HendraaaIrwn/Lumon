import SwiftUI

struct ClueDotsView: View {
    let clues: [ColorClue]

    private var rowCount: Int {
        min(2, (clues.count + 2) / 3)
    }

    var body: some View {
        Grid(horizontalSpacing: 5, verticalSpacing: 5) {
            ForEach(0..<rowCount, id: \.self) { row in
                GridRow {
                    ForEach(row * 3..<min(row * 3 + 3, clues.count), id: \.self) { index in
                        Circle()
                            .fill(clues[index].color.swiftUIColor)
                            .stroke(.white, lineWidth: 1.5)
                            .frame(maxWidth: 14, maxHeight: 14)
                    }
                }
            }
        }
        .accessibilityHidden(true)
    }
}
