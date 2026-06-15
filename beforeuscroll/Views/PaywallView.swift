import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject private var appState: BYSAppState
    @Environment(\.dismiss) private var dismiss

    let onComplete: (() -> Void)?

    @ObservedObject private var storeKitService = StoreKitService.shared
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var pulse = false

    init(onComplete: (() -> Void)? = nil) {
        self.onComplete = onComplete
    }

    var body: some View {
        ZStack {
            background

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    hero
                    featureComparison
                    productList

                    if let message = storeKitService.purchaseErrorMessage {
                        errorMessage(message)
                    }

                    if appState.settings.isPremium {
                        BYSPrimaryButton(title: "Done", systemImage: "checkmark") {
                            onComplete?()
                            dismiss()
                        }
                    } else {
                        BYSPrimaryButton(title: purchaseButtonTitle, systemImage: "crown.fill") {
                            Task {
                                await purchaseSelectedProduct()
                            }
                        }
                        .disabled(selectedProduct == nil || isPurchasing)

                        BYSSecondaryButton(title: isRestoring ? "Restoring..." : "Restore Purchases", systemImage: "arrow.clockwise") {
                            Task { await restore() }
                        }
                        .disabled(isRestoring)

                        Button("Continue Free") {
                            dismiss()
                        }
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(BYSTheme.textMuted)
                        .padding(.top, 2)
                    }

                    legalFooter
                }
                .padding(22)
            }
        }
        .task {
            await storeKitService.configure()
            selectedProduct = selectedProduct ?? preferredProduct
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    private var background: some View {
        ZStack {
            BYSTheme.background.ignoresSafeArea()

            RadialGradient(
                colors: [BYSTheme.gold.opacity(0.28), .clear],
                center: .topLeading,
                startRadius: 20,
                endRadius: 440
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [BYSTheme.violet.opacity(0.21), .clear],
                center: .topTrailing,
                startRadius: 60,
                endRadius: 430
            )
            .ignoresSafeArea()
        }
    }

    private var hero: some View {
        VStack(spacing: 18) {
            BYSBrandMark(size: .large, showsGlow: true, showsBackground: true)
                .padding(.top, 12)

            VStack(spacing: 8) {
                Text(appState.settings.isPremium ? "Premium Active" : "Keep your Flame burning longer")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(BYSTheme.text)
                    .multilineTextAlignment(.center)

                Text(appState.settings.isPremium ? "Thank you for supporting BeforeUScroll." : "More room for intentional time after Scripture and prayer.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(BYSTheme.textMuted)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var featureComparison: some View {
        BYSGlassCard(padding: 16, cornerRadius: 24) {
            VStack(spacing: 14) {
                HStack {
                    Text("Free")
                        .font(.headline.bold())
                        .foregroundStyle(BYSTheme.textMuted)

                    Spacer()

                    Text("Premium")
                        .font(.headline.bold())
                        .foregroundStyle(BYSTheme.gold)
                }

                comparisonRow("Daily flame cap", free: "30 min", premium: "3 hours")
                comparisonRow("Scripture refill", free: "+10 min", premium: "+15 min")
                comparisonRow("Prayer recharge", free: "1x rate", premium: "2x rate")
                comparisonRow("Custom Flame colors", free: "Ember only", premium: "7 themes")
            }
        }
    }

    private func comparisonRow(_ title: String, free: String, premium: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BYSTheme.text)

            Spacer()

            Text(free)
                .font(.caption.weight(.bold))
                .foregroundStyle(BYSTheme.textFaint)
                .frame(width: 76, alignment: .trailing)

            Text(premium)
                .font(.caption.weight(.black))
                .foregroundStyle(BYSTheme.gold)
                .frame(width: 94, alignment: .trailing)
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.055))
        )
    }

    private var productList: some View {
        VStack(spacing: 12) {
            if appState.settings.isPremium {
                EmptyView()
            } else if storeKitService.isLoading && storeKitService.products.isEmpty {
                BYSCard(padding: 16) {
                    HStack {
                        ProgressView()
                        Text("Loading Premium options...")
                            .foregroundStyle(BYSTheme.textMuted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else if storeKitService.products.isEmpty {
                BYSCard(padding: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Premium options unavailable")
                            .font(.headline)
                            .foregroundStyle(BYSTheme.text)

                        Text("Premium is not available right now. Please try again later.")
                            .font(.subheadline)
                            .foregroundStyle(BYSTheme.textMuted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else if visibleProducts.isEmpty {
                BYSCard(padding: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Premium options unavailable")
                            .font(.headline)
                            .foregroundStyle(BYSTheme.text)

                        Text("Monthly and yearly Premium options are not available right now.")
                            .font(.subheadline)
                            .foregroundStyle(BYSTheme.textMuted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                ForEach(Array(visibleProducts.enumerated()), id: \.element.id) { index, product in
                    productRow(product)
                        .cardEntrance(delay: Double(index) * 0.055)
                }
            }
        }
    }

    private var visibleProducts: [Product] {
        let preferredOrder = [BYSProductIDs.monthly, BYSProductIDs.yearly]
        let visible = preferredOrder.compactMap { id in
            storeKitService.products.first(where: { $0.id == id })
        }
        return visible.isEmpty ? storeKitService.products.filter { $0.id != BYSProductIDs.weekly } : visible
    }

    private func productRow(_ product: Product) -> some View {
        let isSelected = selectedProduct?.id == product.id

        return Button {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.74)) {
                selectedProduct = product
            }
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(displayName(for: product))
                            .font(.headline.bold())
                            .foregroundStyle(BYSTheme.text)

                        if product.id == BYSProductIDs.yearly {
                            Text("Best Value")
                                .font(.caption2.weight(.black))
                                .foregroundStyle(Color.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(BYSTheme.gold))
                        }
                    }

                    Text(description(for: product))
                        .font(.subheadline)
                        .foregroundStyle(BYSTheme.textMuted)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 7) {
                    Text(product.displayPrice)
                        .font(.headline.weight(.black))
                        .foregroundStyle(BYSTheme.gold)

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? BYSTheme.gold : BYSTheme.textFaint)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(isSelected ? BYSTheme.gold.opacity(0.13) : Color.white.opacity(0.07))
                    .overlay(
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .stroke(isSelected ? BYSTheme.gold.opacity(0.65) : BYSTheme.border, lineWidth: 1.2)
                    )
            )
            .scaleEffect(isSelected ? 1.018 : 1.0)
        }
        .buttonStyle(PressableScaleButtonStyle())
    }

    private var preferredProduct: Product? {
        visibleProducts.first(where: { $0.id == BYSProductIDs.yearly }) ?? visibleProducts.first
    }

    private var purchaseButtonTitle: String {
        guard let selectedProduct else {
            return "Choose an Option"
        }

        if isPurchasing {
            return "Purchasing..."
        }

        return "Choose \(displayName(for: selectedProduct))"
    }

    private func purchaseSelectedProduct() async {
        guard let selectedProduct else { return }

        isPurchasing = true
        let success = await storeKitService.purchase(selectedProduct)
        await appState.syncPremiumStatus()
        isPurchasing = false

        if success {
            onComplete?()
            dismiss()
        }
    }

    private func restore() async {
        isRestoring = true
        let restored = await storeKitService.restorePurchases()
        appState.settings.isPremium = restored
        isRestoring = false

        if restored {
            onComplete?()
            dismiss()
        }
    }

    private func errorMessage(_ message: String) -> some View {
        Text(message)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(BYSTheme.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(BYSTheme.red.opacity(0.12))
            )
    }

    private func displayName(for product: Product) -> String {
        switch product.id {
        case BYSProductIDs.weekly:
            return "Weekly"
        case BYSProductIDs.monthly:
            return "Monthly"
        case BYSProductIDs.yearly:
            return "Yearly"
        default:
            return product.displayName
        }
    }

    private func description(for product: Product) -> String {
        switch product.id {
        case BYSProductIDs.weekly:
            return "Try Premium with the shortest commitment."
        case BYSProductIDs.monthly:
            return "Flexible support month to month."
        case BYSProductIDs.yearly:
            return "Best value for a larger daily flame cap."
        default:
            return product.description.isEmpty ? "Upgrade to Premium." : product.description
        }
    }

    private var legalFooter: some View {
        VStack(spacing: 8) {
            Text("Purchases are handled through your Apple ID. Subscriptions renew automatically unless canceled at least 24 hours before renewal.")
                .font(.caption)
                .foregroundStyle(BYSTheme.textFaint)
                .multilineTextAlignment(.center)

            HStack(spacing: 14) {
                Link("Privacy", destination: AppLinks.privacy)
                Link("Terms", destination: AppLinks.terms)
                Link("Support", destination: AppLinks.support)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(BYSTheme.gold)
        }
        .padding(.top, 4)
    }
}

#Preview {
    PaywallView()
        .environmentObject(BYSAppState())
}
