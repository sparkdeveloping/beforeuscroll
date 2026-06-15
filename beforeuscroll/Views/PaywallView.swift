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

    init(onComplete: (() -> Void)? = nil) {
        self.onComplete = onComplete
    }

    var body: some View {
        ZStack {
            BYSTheme.background.ignoresSafeArea()

            RadialGradient(
                colors: [BYSTheme.gold.opacity(0.28), .clear],
                center: .top,
                startRadius: 20,
                endRadius: 440
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {
                    Image(systemName: appState.settings.isPremium ? "checkmark.seal.fill" : "sparkles")
                        .font(.system(size: 52, weight: .medium))
                        .foregroundStyle(BYSTheme.gold)
                        .padding(.top, 24)

                    BYSHeader(
                        eyebrow: "Premium",
                        title: appState.settings.isPremium ? "Premium Active" : "Support BeforeUScroll",
                        subtitle: appState.settings.isPremium ? "Thank you for supporting a calmer, Christ-centered way to use your phone." : "The core verse check is free. Premium adds stronger boundaries and helps keep the app available."
                    )

                    VStack(spacing: 12) {
                        feature("Unlimited protected apps")
                        feature("15/30-minute unlocks")
                        feature("More schedules")
                        feature("Strict mode")
                        feature("More verse packs")
                    }

                    if appState.settings.isPremium {
                        BYSPrimaryButton(title: "Done", systemImage: "checkmark") {
                            onComplete?()
                            dismiss()
                        }
                    } else {
                        productList

                        if let message = storeKitService.purchaseErrorMessage {
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

                        BYSPrimaryButton(title: purchaseButtonTitle, systemImage: "heart.fill") {
                            Task {
                                await purchaseSelectedProduct()
                            }
                        }
                        .disabled(selectedProduct == nil || isPurchasing)

                        BYSSecondaryButton(title: isRestoring ? "Restoring..." : "Restore Purchases", systemImage: "arrow.clockwise") {
                            Task {
                                await restore()
                            }
                        }
                        .disabled(isRestoring)

                        BYSSecondaryButton(title: "Continue Free") {
                            dismiss()
                        }
                    }

                    legalFooter
                }
                .padding(24)
            }
        }
        .task {
            await storeKitService.configure()
            selectedProduct = selectedProduct ?? storeKitService.products.first
        }
    }

    private var productList: some View {
        VStack(spacing: 12) {
            if storeKitService.isLoading && storeKitService.products.isEmpty {
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

                        Text("Make sure the products are created in App Store Connect or available in your StoreKit configuration.")
                            .font(.subheadline)
                            .foregroundStyle(BYSTheme.textMuted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                ForEach(storeKitService.products, id: \.id) { product in
                    productRow(product)
                }
            }
        }
    }

    private func productRow(_ product: Product) -> some View {
        Button {
            selectedProduct = product
        } label: {
            BYSCard(padding: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 8) {
                            Text(displayName(for: product))
                                .font(.headline)
                                .foregroundStyle(BYSTheme.text)

                            if product.id == BYSProductIDs.yearly {
                                Text("Best Value")
                                    .font(.caption.bold())
                                    .foregroundStyle(Color.black)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(BYSTheme.gold))
                            }
                        }

                        Text(product.description.isEmpty ? description(for: product) : product.description)
                            .font(.subheadline)
                            .foregroundStyle(BYSTheme.textMuted)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 6) {
                        Text(product.displayPrice)
                            .font(.headline)
                            .foregroundStyle(BYSTheme.gold)

                        Image(systemName: selectedProduct?.id == product.id ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedProduct?.id == product.id ? BYSTheme.gold : BYSTheme.textFaint)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var purchaseButtonTitle: String {
        guard let selectedProduct else {
            return "Choose an Option"
        }

        if isPurchasing {
            return "Purchasing..."
        }

        return "Continue with \(displayName(for: selectedProduct))"
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

    private func feature(_ title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(BYSTheme.green)

            Text(title)
                .foregroundStyle(BYSTheme.text)

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.065))
        )
    }

    private func displayName(for product: Product) -> String {
        switch product.id {
        case BYSProductIDs.monthly:
            return "Monthly"
        case BYSProductIDs.yearly:
            return "Yearly"
        case BYSProductIDs.weekly:
            return "Weekly"
        default:
            return product.displayName
        }
    }

    private func description(for product: Product) -> String {
        switch product.id {
        case BYSProductIDs.monthly:
            return "Simple monthly support."
        case BYSProductIDs.yearly:
            return "Best value for ongoing support."
        case BYSProductIDs.weekly:
            return "One-time early premium option."
        default:
            return "Support BeforeUScroll."
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
        .padding(.top, 6)
    }
}

#Preview {
    PaywallView()
        .environmentObject(BYSAppState())
}
