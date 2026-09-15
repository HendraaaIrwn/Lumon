import Foundation
import Observation

@MainActor
@Observable
final class ProgressStore {
    private enum Key {
        static let completedLevelIDs = "lumon.progress.completedLevelIDs"
    }

    let levelIDs: [String]
    private let defaults: UserDefaults
    private(set) var completedLevelIDs: Set<String>

    init(
        levelIDs: [String] = BundleLevelRepository().availableLevelIDs,
        defaults: UserDefaults = .standard
    ) {
        self.levelIDs = levelIDs
        self.defaults = defaults
        let stored = defaults.stringArray(forKey: Key.completedLevelIDs) ?? []
        completedLevelIDs = Set(stored).intersection(levelIDs)
    }

    var firstUnfinishedLevelID: String? {
        levelIDs.first { !completedLevelIDs.contains($0) }
    }

    func markCompleted(_ levelID: String) {
        guard levelIDs.contains(levelID), completedLevelIDs.insert(levelID).inserted else { return }
        persist()
    }

    func isCompleted(_ levelID: String) -> Bool {
        completedLevelIDs.contains(levelID)
    }

    func isUnlocked(_ levelID: String) -> Bool {
        guard let index = levelIDs.firstIndex(of: levelID) else { return false }
        return index == 0 || levelIDs[..<index].allSatisfy(completedLevelIDs.contains)
    }

    func nextLevelID(after levelID: String) -> String? {
        guard let index = levelIDs.firstIndex(of: levelID), index + 1 < levelIDs.count else {
            return nil
        }
        return levelIDs[index + 1]
    }

    func resetProgress() {
        completedLevelIDs.removeAll()
        defaults.removeObject(forKey: Key.completedLevelIDs)
    }

    private func persist() {
        let ordered = levelIDs.filter(completedLevelIDs.contains)
        defaults.set(ordered, forKey: Key.completedLevelIDs)
    }
}
