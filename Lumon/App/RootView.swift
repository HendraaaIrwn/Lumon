import SwiftUI

/// Home screen (GDD §12) in the Apple-minimal visual style (GDD §11):
/// clean white background, geometric wordmark, strong whitespace.
/// Navigation wiring arrives in later phases — this is the TASK-003 stub.
struct RootView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 10) {
                    Text("LUMON")
                        .font(.largeTitle.weight(.heavy))
                        .fontDesign(.rounded)
                        .tracking(8)
                        .foregroundStyle(.black)

                    Text("Reveal the hidden colors.")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(spacing: 20) {
                    NavigationLink(value: AppDestination.game(levelID: "level_001")) {
                        Text("PLAY")
                            .font(.title3.weight(.semibold))
                            .tracking(3)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                .black,
                                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                            )
                    }
                    .padding(.horizontal, 40)

                    HStack(spacing: 36) {
                        Text("Level Select")
                        Text("Settings")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                }
                .padding(.bottom, 56)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(white: 0.97))
            .navigationDestination(for: AppDestination.self) { destination in
                switch destination {
                case .game(let levelID):
                    GameView(levelID: levelID)
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    RootView()
}
