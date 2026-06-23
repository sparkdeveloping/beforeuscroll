import Foundation
import StoreKit
import Combine

enum BYSPremiumProductState: Equatable {
    case idle
    case loading
    case loaded
    case unavailable(String)
}

@MainActor
final class StoreKitService: ObservableObject {
    static let shared = StoreKitService()

    @Published private(set) var productState: BYSPremiumProductState = .idle
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading = false
    @Published var purchaseErrorMessage: String?

    private var updatesTask: Task<Void, Never>?

    private init() {
        updatesTask = listenForTransactions()
    }

    deinit {
        updatesTask?.cancel()
    }

    var isPremium: Bool {
        !purchasedProductIDs.isDisjoint(with: Set(BYSProductIDs.all))
    }

    func configure() async {
        await loadProducts(force: false)
        await updatePurchasedProducts()
    }

    func loadProducts(force: Bool = false) async {
        if isLoading { return }
        if !force, !products.isEmpty { return }

        isLoading = true
        productState = .loading
        purchaseErrorMessage = nil

        let requested = BYSProductIDs.all
        print("BYS products requested:", BYSProductIDs.ordered)

        for attempt in 1...3 {
            do {
                let loadedProducts = try await Product.products(for: requested)
                let returned = Set(loadedProducts.map(\.id))
                let missing = requested.subtracting(returned)

                print("BYS StoreKit attempt:", attempt)
                print("BYS StoreKit returned IDs:", returned)
                print("BYS StoreKit missing IDs:", missing)

                if !loadedProducts.isEmpty {
                    products = loadedProducts.sorted { lhs, rhs in
                        sortIndex(for: lhs.id) < sortIndex(for: rhs.id)
                    }
                    productState = .loaded
                    isLoading = false
                    return
                }
            } catch {
                print("BYS StoreKit load failed attempt \(attempt):", error)
                purchaseErrorMessage = error.localizedDescription
            }

            try? await Task.sleep(nanoseconds: UInt64(attempt) * 700_000_000)
        }

        products = []
        productState = .unavailable("Premium is temporarily unavailable. Please try again shortly.")
        isLoading = false
    }

    func purchase(_ product: Product) async -> Bool {
        purchaseErrorMessage = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updatePurchasedProducts()
                return true

            case .userCancelled:
                return false

            case .pending:
                purchaseErrorMessage = "Purchase is pending approval."
                return false

            @unknown default:
                purchaseErrorMessage = "Purchase could not be completed."
                return false
            }
        } catch {
            purchaseErrorMessage = "Purchase failed. Please try again."
            print("Purchase failed: \(error)")
            return false
        }
    }

    func restorePurchases() async -> Bool {
        purchaseErrorMessage = nil

        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            return isPremium
        } catch {
            purchaseErrorMessage = "Could not restore purchases. Please try again."
            print("Restore failed: \(error)")
            return false
        }
    }

    func updatePurchasedProducts() async {
        var purchased = Set<String>()

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                guard BYSProductIDs.all.contains(transaction.productID) else { continue }

                if transaction.revocationDate == nil {
                    purchased.insert(transaction.productID)
                }
            } catch {
                print("Unverified transaction ignored: \(error)")
            }
        }

        purchasedProductIDs = purchased
        print("BYS StoreKit purchased IDs:", purchasedProductIDs)
        print("BYS StoreKit premium active:", isPremium)
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task {
            for await update in Transaction.updates {
                do {
                    let transaction = try checkVerified(update)
                    await transaction.finish()
                    await updatePurchasedProducts()
                } catch {
                    print("Transaction update verification failed: \(error)")
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            throw StoreKitError.failedVerification
        }
    }

    private func sortIndex(for productID: String) -> Int {
        switch productID {
        case BYSProductIDs.yearly:
            return 0
        case BYSProductIDs.monthly:
            return 1
        case BYSProductIDs.weekly:
            return 2
        default:
            return 99
        }
    }
}

enum StoreKitError: Error {
    case failedVerification
}
