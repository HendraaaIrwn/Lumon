import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettings
    let progressStore: ProgressStore
    @State private var showsResetConfirmation = false

    var body: some View {
        Form {
            Section("Audio") {
                Toggle("Sound Effects", isOn: $settings.isSoundEnabled)
            }
            Section("Progress") {
                Button("Reset Progress", role: .destructive) {
                    showsResetConfirmation = true
                }
                .disabled(progressStore.completedLevelIDs.isEmpty)
            }
        }
        .navigationTitle("Settings")
        .confirmationDialog(
            "Reset all level progress?",
            isPresented: $showsResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset Progress", role: .destructive) {
                progressStore.resetProgress()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Level 2 through Level 10 will be locked again.")
        }
    }
}
