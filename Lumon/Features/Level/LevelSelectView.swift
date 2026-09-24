import SwiftUI

struct LevelSelectView: View {
    let progressStore: ProgressStore
    let onSelect: (String) -> Void
    private let columns = [GridItem(.adaptive(minimum: 92), spacing: 14)]

    var body: some View {
        LumonScreenBackground {
            VStack(spacing: 0) {
                LumonNavigationHeader(title: "Level Select")

                ScrollView {
                    LazyVGrid(columns: columns, spacing: LumonSpacing.md) {
                        ForEach(Array(progressStore.levelIDs.enumerated()), id: \.element) { index, levelID in
                            levelTile(index: index, levelID: levelID)
                        }
                    }
                    .padding(.horizontal, LumonSpacing.lg)
                    .padding(.vertical, LumonSpacing.md)
                    .frame(maxWidth: 760)
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }

    private func levelTile(index: Int, levelID: String) -> some View {
        let unlocked = progressStore.isUnlocked(levelID)
        let completed = progressStore.isCompleted(levelID)
        let current = progressStore.firstUnfinishedLevelID == levelID

        return Button {
            if unlocked {
                onSelect(levelID)
            }
        } label: {
            VStack(spacing: LumonSpacing.sm) {
                Image(systemName: shapeIcon(for: index))
                    .font(.system(size: 24, weight: .bold))
                Text(String(format: "%02d", index + 1))
                    .lumonTextStyle(.title1, tracking: -0.2)
            }
            .frame(maxWidth: .infinity, minHeight: 112)
            .foregroundStyle(foreground(for: completed, current: current, unlocked: unlocked))
            .background(fill(for: completed, current: current), in: RoundedRectangle(cornerRadius: LumonRadius.small))
            .overlay {
                RoundedRectangle(cornerRadius: LumonRadius.small)
                    .stroke(
                        stroke(for: completed, current: current, unlocked: unlocked),
                        lineWidth: current ? LumonStroke.medium : LumonStroke.thin
                    )
            }
            .opacity(unlocked ? 1 : 0.48)
        }
        .buttonStyle(.plain)
        .disabled(!unlocked)
        .accessibilityLabel(label(index: index, levelID: levelID, unlocked: unlocked))
    }

    private func shapeIcon(for index: Int) -> String {
        ["triangle.fill", "square.fill", "diamond.fill", "circle.fill"][index % 4]
    }

    private func fill(for completed: Bool, current: Bool) -> Color {
        if completed { return LumonPalette.cream }
        if current { return LumonPalette.orange }
        return LumonPalette.ink.opacity(0.62)
    }

    private func foreground(for completed: Bool, current: Bool, unlocked: Bool) -> Color {
        if completed || current { return LumonPalette.background }
        return unlocked ? LumonPalette.cream : LumonPalette.cream.opacity(0.70)
    }

    private func stroke(for completed: Bool, current: Bool, unlocked: Bool) -> Color {
        if completed { return LumonPalette.cream }
        if current { return LumonPalette.cream }
        return unlocked ? LumonPalette.cream.opacity(0.72) : LumonPalette.cream.opacity(0.40)
    }

    private func label(index: Int, levelID: String, unlocked: Bool) -> String {
        let state = progressStore.isCompleted(levelID)
            ? "Completed"
            : (unlocked ? "Available" : "Locked")
        return "Level \(index + 1), \(state)"
    }
}
