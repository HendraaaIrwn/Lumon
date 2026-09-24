import SwiftUI

struct GameHUD: View {
    @Environment(\.dismiss) private var dismiss

    let order: Int
    let title: String
    let lives: Int
    let showLives: Bool

    var body: some View {
        HStack(spacing: LumonSpacing.smPlus) {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .heavy))
                    .frame(width: 44, height: 44)
                    .overlay { Rectangle().stroke(LumonPalette.cream.opacity(0.55), lineWidth: 2) }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")

            VStack(alignment: .leading, spacing: 0) {
                Text(String(format: "LEVEL %02d", order))
                    .lumonTextStyle(.label, color: LumonPalette.orange, tracking: 1.2)
                Text(title)
                    .lumonTextStyle(.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)

            Spacer(minLength: 4)
            if showLives {
                LumonLivesView(lives: lives)
            }
        }
        .foregroundStyle(LumonPalette.cream)
        .padding(.horizontal, LumonSpacing.lg)
        .padding(.top, LumonSpacing.sm)
        .frame(minHeight: 60)
    }
}

struct GameInstruction: View {
    let title: String
    let message: String
    let isTutorial: Bool

    var body: some View {
        VStack(spacing: 3) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(isTutorial ? LumonPalette.orange : LumonPalette.cream)
                    .frame(width: 12, height: 4)
                Text(title)
                    .lumonTextStyle(.label, tracking: 0.8)
                Rectangle()
                    .fill(isTutorial ? LumonPalette.orange : LumonPalette.cream)
                    .frame(width: 12, height: 4)
            }
            Text(message)
                .lumonTextStyle(.caption, color: LumonPalette.cream.opacity(0.82))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

struct GameActions: View {
    let hints: Int
    let canUseHint: Bool
    let onHint: () -> Void
    let onReset: () -> Void

    var body: some View {
        HStack(spacing: LumonSpacing.smPlus) {
            Button(action: onHint) {
                HStack(spacing: 10) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 16, weight: .bold))
                    Text("HINT")
                        .lumonTextStyle(.label, color: LumonPalette.background, tracking: 1)
                    Spacer(minLength: 0)
                    Text("\(hints)")
                        .lumonTextStyle(.label, color: LumonPalette.background)
                        .padding(.horizontal, 9)
                        .frame(minHeight: 28)
                        .background(LumonPalette.orange, in: Rectangle())
                }
                .foregroundStyle(LumonPalette.background)
            }
            .buttonStyle(.lumonPrimary)
            .disabled(!canUseHint)
            .opacity(canUseHint ? 1 : 0.55)
            .accessibilityLabel("Hint, \(hints) remaining")

            Button(action: onReset) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 18, weight: .bold))
                    .frame(width: 56, height: 56)
                    .foregroundStyle(LumonPalette.cream)
                    .overlay { Rectangle().stroke(LumonPalette.cream, lineWidth: 2) }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Reset level")
        }
    }
}

struct GameResult: View {
    let isComplete: Bool
    let isFinalLevel: Bool
    let onPrimary: () -> Void
    let onReplay: () -> Void
    let onHome: () -> Void

    var body: some View {
        VStack(spacing: LumonSpacing.smPlus) {
            HStack(spacing: 10) {
                Rectangle()
                    .fill(accent)
                    .frame(width: 20, height: 5)
                    .rotationEffect(.degrees(-22))
                Circle()
                    .fill(LumonPalette.blue)
                    .frame(width: 9, height: 9)
                Rectangle()
                    .fill(LumonPalette.yellow)
                    .frame(width: 11, height: 11)
                    .rotationEffect(.degrees(25))
            }
            .accessibilityHidden(true)

            Text(title)
                .lumonTextStyle(.title1)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.75)
                .lineLimit(2)
                .accessibilityAddTraits(.isHeader)

            Text(isComplete ? "Every piece in its place." : "Take another look at the clues.")
                .lumonTextStyle(.caption, color: LumonPalette.cream.opacity(0.8))
                .multilineTextAlignment(.center)

            Button(primaryTitle, action: onPrimary)
                .buttonStyle(.lumonPrimary)
                .padding(.top, LumonSpacing.sm)

            HStack(spacing: LumonSpacing.lg) {
                if isComplete {
                    Button("REPLAY", action: onReplay)
                        .accessibilityLabel("Replay level")
                }
                Button("HOME", action: onHome)
            }
            .buttonStyle(.plain)
            .lumonTextStyle(.label)
            .frame(minHeight: 44)
        }
        .frame(maxWidth: 360)
        .frame(maxWidth: .infinity)
    }

    private var accent: Color { isComplete ? LumonPalette.orange : LumonPalette.coral }
    private var title: String {
        if !isComplete { return "GAME OVER" }
        return isFinalLevel ? "ALL LEVELS COMPLETE" : "LEVEL COMPLETE"
    }
    private var primaryTitle: String {
        if !isComplete { return "TRY AGAIN" }
        return isFinalLevel ? "LEVEL SELECT" : "NEXT LEVEL"
    }
}

/// Small geometric marks stay at the artwork's edge during the completion pulse.
struct GameCelebrationAccents: View {
    let trigger: UUID?
    let reduceMotion: Bool
    @State private var visible = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Circle()
                    .fill(LumonPalette.orange)
                    .frame(width: 14, height: 14)
                    .position(x: 14, y: proxy.size.height * 0.30)

                Rectangle()
                    .fill(LumonPalette.yellow)
                    .frame(width: 12, height: 12)
                    .rotationEffect(.degrees(24))
                    .position(x: proxy.size.width - 16, y: proxy.size.height * 0.16)

                Rectangle()
                    .fill(LumonPalette.blue)
                    .frame(width: 20, height: 5)
                    .rotationEffect(.degrees(-18))
                    .position(x: proxy.size.width - 12, y: proxy.size.height * 0.82)
            }
            .opacity(visible ? 1 : 0)
            .scaleEffect(visible ? 1 : 0.8)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .task(id: trigger) {
            visible = false
            guard trigger != nil, !reduceMotion else { return }
            withAnimation(.easeOut(duration: 0.18)) { visible = true }
            try? await Task.sleep(for: .milliseconds(640))
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.18)) { visible = false }
        }
    }
}

#Preview("Game result") {
    LumonScreenBackground(variant: .game) {
        GameResult(isComplete: true, isFinalLevel: false, onPrimary: {}, onReplay: {}, onHome: {})
            .padding()
    }
}

#Preview("Final level result") {
    LumonScreenBackground(variant: .game) {
        GameResult(isComplete: true, isFinalLevel: true, onPrimary: {}, onReplay: {}, onHome: {})
            .padding()
    }
}

#Preview("Game over result") {
    LumonScreenBackground(variant: .game) {
        GameResult(isComplete: false, isFinalLevel: false, onPrimary: {}, onReplay: {}, onHome: {})
            .padding()
    }
}

#Preview("Completion with board") {
    LumonScreenBackground(variant: .game) {
        VStack(spacing: 0) {
            GameHUD(order: 1, title: "First Light", lives: 3, showLives: false)
            Spacer(minLength: 8)
            GameBoardView(
                shapes: completionPreviewShapes,
                selectedShapeID: nil,
                revealedClueShapeIDs: Set(completionPreviewShapes.map(\.id)),
                selectableShapeIDs: nil,
                tutorialHighlightedShapeIDs: [],
                feedbackEvent: nil,
                onSelectShape: { _ in }
            )
            .frame(maxWidth: 360)
            .aspectRatio(1, contentMode: .fit)
            .allowsHitTesting(false)
            Spacer(minLength: 12)
            GameResult(isComplete: true, isFinalLevel: false, onPrimary: {}, onReplay: {}, onHome: {})
                .padding(.horizontal, LumonSpacing.lg)
            Spacer(minLength: 16)
        }
    }
}

private var completionPreviewShapes: [PuzzleShape] {
    [
        PuzzleShape(id: "upper_left", type: .triangle,
                    position: NormalizedPoint(x: 0.231, y: 0.275), rotation: 180,
                    size: NormalizedSize(width: 0.462, height: 0.404), color: .red,
                    clues: [ColorClue(color: .yellow)]),
        PuzzleShape(id: "center", type: .triangle,
                    position: NormalizedPoint(x: 0.504, y: 0.292),
                    size: NormalizedSize(width: 0.468, height: 0.399), color: .yellow,
                    clues: Array(repeating: ColorClue(color: .red), count: 3)),
        PuzzleShape(id: "upper_right", type: .triangle,
                    position: NormalizedPoint(x: 0.768, y: 0.269), rotation: 180,
                    size: NormalizedSize(width: 0.462, height: 0.404), color: .red,
                    clues: [ColorClue(color: .yellow)]),
        PuzzleShape(id: "bottom", type: .triangle,
                    position: NormalizedPoint(x: 0.506, y: 0.730), rotation: 180,
                    size: NormalizedSize(width: 0.462, height: 0.404), color: .red),
    ]
}
