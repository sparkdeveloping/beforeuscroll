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
    @State private var presentedURL: BYSLinkSheetURL?

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

                    ctaArea
                    requiredDisclosure
                    legalFooter
                }
                .padding(22)
            }
        }
        .task {
            await storeKitService.loadProducts(force: true)
            selectPreferredProductIfNeeded()
        }
        .onChange(of: storeKitService.products.map(\.id)) { _, _ in
            selectPreferredProductIfNeeded()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
        .sheet(item: $presentedURL) { item in
            SafariWebSheet(url: item.url)
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
            } else if storeKitService.productState == .idle || storeKitService.productState == .loading {
                BYSCard(padding: 16) {
                    HStack {
                        ProgressView()
                        Text("Loading Premium…")
                            .foregroundStyle(BYSTheme.textMuted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else if case .unavailable = storeKitService.productState {
                BYSCard(padding: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Premium is temporarily unavailable.")
                            .font(.headline)
                            .foregroundStyle(BYSTheme.text)

                        Text("Please check your connection or try again shortly.")
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
        storeKitService.products
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
                        Text(product.displayName)
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

                    Text(billingPeriodLabel(for: product))
                        .font(.subheadline)
                        .foregroundStyle(BYSTheme.textMuted)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 7) {
                    Text(product.displayPrice)
                        .font(.headline.weight(.black))
                        .foregroundStyle(BYSTheme.gold)

                    if let perMonth = monthlyEquivalent(for: product) {
                        Text(perMonth)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(BYSTheme.textFaint)
                    }

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

    private var ctaArea: some View {
        Group {
            if appState.settings.isPremium {
                BYSPrimaryButton(title: "Done", systemImage: "checkmark") {
                    onComplete?()
                    dismiss()
                }
            } else if storeKitService.productState == .idle || storeKitService.productState == .loading {
                BYSPrimaryButton(title: "Loading Premium…", systemImage: "crown.fill") { }
                    .disabled(true)
            } else if case .unavailable = storeKitService.productState {
                VStack(spacing: 12) {
                    BYSPrimaryButton(title: "Try Again", systemImage: "arrow.clockwise") {
                        Task {
                            await retryLoadingProducts()
                        }
                    }
                    BYSSecondaryButton(title: "Continue Free", systemImage: "xmark") {
                        dismiss()
                    }
                }
            } else {
                VStack(spacing: 12) {
                    BYSPrimaryButton(title: purchaseButtonTitle, systemImage: "crown.fill") {
                        Task {
                            await purchaseSelectedProduct()
                        }
                    }
                    .disabled(selectedProduct == nil || isPurchasing || visibleProducts.isEmpty)

                    BYSSecondaryButton(title: isRestoring ? "Restoring…" : "Restore Purchases", systemImage: "arrow.clockwise") {
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
            }
        }
    }

    private var requiredDisclosure: some View {
        Group {
            if !appState.settings.isPremium,
               storeKitService.productState != .idle,
               storeKitService.productState != .loading,
               !visibleProducts.isEmpty {
                if case .unavailable = storeKitService.productState {
                    EmptyView()
                } else {
                    Text("Payment will be charged to your Apple Account at purchase confirmation. Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period.")
                        .font(.caption2)
                        .foregroundStyle(BYSTheme.textFaint)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
            }
        }
    }

    private var legalFooter: some View {
        VStack(spacing: 10) {
            Text("Manage or cancel your subscription in your Apple Account settings after purchase.")
                .font(.caption2)
                .foregroundStyle(BYSTheme.textFaint)
                .multilineTextAlignment(.center)

            HStack(spacing: 18) {
                Button("Privacy Policy") {
                    presentedURL = BYSLinkSheetURL(url: AppLinks.privacy)
                }
                Button("Terms of Use") {
                    presentedURL = BYSLinkSheetURL(url: AppLinks.terms)
                }
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(BYSTheme.gold)
        }
        .padding(.top, 4)
    }

    private var purchaseButtonTitle: String {
        isPurchasing ? "Purchasing…" : "Start Premium"
    }

    private func selectPreferredProductIfNeeded() {
        guard !visibleProducts.isEmpty else {
            selectedProduct = nil
            return
        }

        if let selectedProduct, visibleProducts.contains(where: { $0.id == selectedProduct.id }) {
            return
        }

        selectedProduct = preferredProduct
    }

    private func retryLoadingProducts() async {
        await storeKitService.loadProducts(force: true)
        selectPreferredProductIfNeeded()
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
        appState.applyRestoredPremiumStatus(restored)
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

    private func billingPeriodLabel(for product: Product) -> String {
        if let period = product.subscription?.subscriptionPeriod {
            switch period.unit {
            case .week:
                return period.value == 1 ? "Billed weekly" : "Billed every \(period.value) weeks"
            case .month:
                return period.value == 1 ? "Billed monthly" : "Billed every \(period.value) months"
            case .year:
                return period.value == 1 ? "Billed annually" : "Billed every \(period.value) years"
            case .day:
                return period.value == 1 ? "Billed daily" : "Billed every \(period.value) days"
            @unknown default:
                return "Subscription"
            }
        }
        switch product.id {
        case BYSProductIDs.weekly: return "Billed weekly"
        case BYSProductIDs.monthly: return "Billed monthly"
        case BYSProductIDs.yearly: return "Billed annually"
        default: return "Subscription"
        }
    }

    private func monthlyEquivalent(for product: Product) -> String? {
        guard product.id == BYSProductIDs.yearly,
              let period = product.subscription?.subscriptionPeriod,
              period.unit == .year,
              period.value == 1 else { return nil }
        let monthly = product.price / 12
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = product.priceFormatStyle.currencyCode
        formatter.maximumFractionDigits = 2
        if let formatted = formatter.string(from: monthly as NSDecimalNumber) {
            return "\(formatted)/mo"
        }
        return nil
    }
}

#Preview {
    PaywallView()
        .environmentObject(BYSAppState())
}
