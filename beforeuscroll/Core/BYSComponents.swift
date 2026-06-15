import SwiftUI

struct BYSCard<Content: View>: View {
    var padding: CGFloat = 18
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(BYSTheme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(BYSTheme.border, lineWidth: 1)
                    )
            )
    }
}

struct BYSPrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                }

                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(Color.black)
            .background(BYSTheme.warmGradient)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: BYSTheme.gold.opacity(0.25), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(.plain)
    }
}

struct BYSSecondaryButton: View {
    let title: String
    var systemImage: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                }

                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(BYSTheme.text)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(BYSTheme.border, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct BYSHeader: View {
    let eyebrow: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(eyebrow.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(BYSTheme.gold)
                .tracking(1.5)

            Text(title)
                .font(.largeTitle.bold())
                .foregroundStyle(BYSTheme.text)
                .minimumScaleFactor(0.8)

            Text(subtitle)
                .font(.body)
                .foregroundStyle(BYSTheme.textMuted)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
