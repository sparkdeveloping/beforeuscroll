import Foundation
import StoreKit
import Combine

@MainActor
final class StoreKitService: ObservableObject {
    static let shared = StoreKitService()

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
        await loadProducts()
        await updatePurchasedProducts()
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let loadedProducts = try await Product.products(for: BYSProductIDs.all)

            products = loadedProducts.sorted { lhs, rhs in
                sortIndex(for: lhs.id) < sortIndex(for: rhs.id)
            }
        } catch {
            purchaseErrorMessage = "Could not load Premium options. Please try again."
            print("Failed loading StoreKit products: \(error)")
        }
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
