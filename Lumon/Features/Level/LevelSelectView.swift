import SwiftUI

struct LevelSelectView: View {
    let progressStore: ProgressStore
    let onSelect: (String) -> Void
    private let columns = [GridItem(.adaptive(minimum: 92), spacing: 14)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(Array(progressStore.levelIDs.enumerated()), id: \.element) { index, levelID in
                    let unlocked = progressStore.isUnlocked(levelID)
                    Button {
                        if unlocked { onSelect(levelID) }
                    } label: {
                        VStack(spacing: 10) {
                            Image(systemName: icon(for: levelID, unlocked: unlocked))
                                .font(.title2)
                            Text("Level \(index + 1)")
                                .font(.headline)
                        }
                        .foregroundStyle(unlocked ? Color.primary : Color.secondary)
                        .frame(maxWidth: .infinity, minHeight: 96)
                        .background(.white, in: RoundedRectangle(cornerRadius: 18))
                        .shadow(color: .black.opacity(unlocked ? 0.06 : 0.02), radius: 10, y: 4)
                    }
                    .buttonStyle(.plain)
                    .disabled(!unlocked)
                    .accessibilityLabel(label(index: index, levelID: levelID, unlocked: unlocked))
                }
            }
            .padding(20)
        }
        .background(Color(white: 0.97))
        .navigationTitle("Level Select")
    }

    private func icon(for levelID: String, unlocked: Bool) -> String {
        if progressStore.isCompleted(levelID) { return "checkmark.circle.fill" }
        return unlocked ? "circle" : "lock.fill"
    }

    private func label(index: Int, levelID: String, unlocked: Bool) -> String {
        let state = progressStore.isCompleted(levelID) ? "Completed" : (unlocked ? "Available" : "Locked")
        return "Level \(index + 1), \(state)"
    }
}
