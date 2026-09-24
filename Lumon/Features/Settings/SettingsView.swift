import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettings
    let progressStore: ProgressStore
    @State private var showsResetConfirmation = false

    var body: some View {
        LumonScreenBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: LumonSpacing.lg) {
                    LumonNavigationHeader(title: "Settings")

                    VStack(alignment: .leading, spacing: LumonSpacing.smPlus) {
                        sectionTitle("AUDIO & FEEDBACK")

                        Toggle("Sound Effects", isOn: $settings.isSoundEnabled)
                            .toggleStyle(LumonToggleStyle())
                            .lumonTextStyle(.body)

                        Toggle("Haptic Feedback", isOn: $settings.isHapticsEnabled)
                            .toggleStyle(LumonToggleStyle())
                            .lumonTextStyle(.body)
                    }

                    VStack(alignment: .leading, spacing: LumonSpacing.smPlus) {
                        sectionTitle("PROGRESS")

                        Button("RESET PROGRESS", role: .destructive) {
                            showsResetConfirmation = true
                        }
                        .buttonStyle(.lumonDestructive)
                        .disabled(progressStore.completedLevelIDs.isEmpty)
                    }
                }
                .padding(.horizontal, LumonSpacing.lg)
                .padding(.bottom, LumonSpacing.xxl)
                .frame(maxWidth: 640)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
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

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .lumonTextStyle(.caption, color: LumonPalette.orange, tracking: 1.2)
            .padding(.horizontal, LumonSpacing.xs)
    }
}
