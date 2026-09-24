import SwiftUI

struct LumonToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: LumonSpacing.md) {
                configuration.label
                    .frame(maxWidth: .infinity, alignment: .leading)

                RoundedRectangle(cornerRadius: LumonRadius.small)
                    .fill(configuration.isOn ? LumonPalette.orange : LumonPalette.ink)
                    .frame(width: 52, height: 30)
                    .overlay(alignment: configuration.isOn ? .trailing : .leading) {
                        Rectangle()
                            .fill(configuration.isOn ? LumonPalette.background : LumonPalette.cream)
                            .frame(width: 22, height: 22)
                            .padding(4)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: LumonRadius.small)
                            .stroke(LumonPalette.cream.opacity(0.65), lineWidth: LumonStroke.thin)
                    }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityValue(configuration.isOn ? "On" : "Off")
        .accessibilityRemoveTraits(.isButton)
        .accessibilityAddTraits(.isToggle)
    }
}

struct LumonSettingsRow<Content: View>: View {
    let title: String
    let subtitle: String?
    let systemImage: String
    @ViewBuilder let content: Content

    init(
        title: String,
        subtitle: String? = nil,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        HStack(spacing: LumonSpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(LumonPalette.orange)
                .frame(width: LumonTouchTarget.minimum, height: LumonTouchTarget.minimum)

            VStack(alignment: .leading, spacing: LumonSpacing.xs) {
                Text(title)
                    .lumonTextStyle(.body)
                if let subtitle {
                    Text(subtitle)
                        .lumonTextStyle(.caption, color: LumonPalette.cream.opacity(0.70))
                }
            }

            Spacer(minLength: LumonSpacing.sm)
            content
        }
        .padding(.horizontal, LumonSpacing.md)
        .padding(.vertical, LumonSpacing.smPlus)
        .background(LumonPalette.ink.opacity(0.70), in: RoundedRectangle(cornerRadius: LumonRadius.medium))
        .overlay {
            RoundedRectangle(cornerRadius: LumonRadius.medium)
                .stroke(LumonPalette.cream.opacity(0.24), lineWidth: LumonStroke.thin)
        }
    }
}
