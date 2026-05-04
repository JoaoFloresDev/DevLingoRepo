import StoreKit
import Foundation

/// Manages in-app purchases with StoreKit 2.
@MainActor
final class PurchaseService: ObservableObject {
    // MARK: - Singleton

    static let shared = PurchaseService()

    // MARK: - Published Properties

    @Published private(set) var isPremium = false
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading = false

    // MARK: - Computed Properties

    var monthlyProduct: Product? {
        products.first { $0.id == AppConstants.monthlyProductID }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == AppConstants.yearlyProductID }
    }

    // MARK: - Private Properties

    private var updateListenerTask: Task<Void, Error>?

    // MARK: - Init

    private init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Public Methods

    func loadProducts() async {
        isLoading = true
        do {
            products = try await Product.products(for: AppConstants.allProductIDs)
                .sorted { $0.price < $1.price }
        } catch {
            print("Failed to load products: \(error)")
        }
        isLoading = false
    }

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            HapticManager.success()
            return true
        case .userCancelled, .pending:
            return false
        @unknown default:
            return false
        }
    }

    func restorePurchases() async {
        try? await AppStore.sync()
        await updatePurchasedProducts()
    }

    // MARK: - Private Methods

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                do {
                    let transaction = try await self?.checkVerified(result)
                    await self?.updatePurchasedProducts()
                    await transaction?.finish()
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    private func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.revocationDate == nil {
                    purchased.insert(transaction.productID)
                }
            }
        }
        purchasedProductIDs = purchased
        isPremium = !purchased.isEmpty
    }
}

// MARK: - Errors

enum StoreError: Error {
    case failedVerification
}
