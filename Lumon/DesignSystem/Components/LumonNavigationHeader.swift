import SwiftUI

struct LumonNavigationHeader<Trailing: View>: View {
    let title: String
    let showsBackButton: Bool
    @ViewBuilder let trailing: Trailing

    @Environment(\.dismiss) private var dismiss

    init(
        title: String,
        showsBackButton: Bool = true,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.showsBackButton = showsBackButton
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: LumonSpacing.smPlus) {
            if showsBackButton {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .frame(width: LumonTouchTarget.minimum, height: LumonTouchTarget.minimum)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(LumonPalette.cream)
                .accessibilityLabel("Back")
            }

            Text(title.uppercased())
                .lumonTextStyle(.title2, tracking: 0.2)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: LumonSpacing.sm)
            trailing
        }
        .padding(.horizontal, LumonSpacing.lg)
        .frame(minHeight: 56)
        .padding(.top, LumonSpacing.sm)
    }
}

extension LumonNavigationHeader where Trailing == EmptyView {
    init(title: String, showsBackButton: Bool = true) {
        self.init(title: title, showsBackButton: showsBackButton) { EmptyView() }
    }
}
