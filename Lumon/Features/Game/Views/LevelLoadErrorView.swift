import SwiftUI

struct LevelLoadErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        ScrollView {
            LumonPanel(stroke: LumonPalette.coral) {
                VStack(spacing: LumonSpacing.md) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(LumonPalette.coral)

                    Text("UNABLE TO LOAD LEVEL")
                        .lumonTextStyle(.title2, tracking: 0.8)
                        .multilineTextAlignment(.center)

                    Text(message)
                        .lumonTextStyle(.body, color: LumonPalette.cream.opacity(0.78))
                        .multilineTextAlignment(.center)

                    Button("RETRY", action: retry)
                        .buttonStyle(.lumonPrimary)
                }
            }
            .padding(LumonSpacing.lg)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity, minHeight: 220)
        }
        .scrollIndicators(.hidden)
    }
}
