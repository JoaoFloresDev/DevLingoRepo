import Foundation

/// UserDefaults-based storage service.
final class StorageService {
    // MARK: - Singleton

    static let shared = StorageService()

    // MARK: - Properties

    private let defaults: UserDefaults

    // MARK: - Init

    private init() {
        defaults = UserDefaults(suiteName: AppConstants.appGroupID) ?? .standard
    }

    // MARK: - Generic

    func set<T: Encodable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    func get<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    // MARK: - Primitives

    func setBool(_ value: Bool, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    func getBool(forKey key: String) -> Bool {
        defaults.bool(forKey: key)
    }

    func setInt(_ value: Int, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    func getInt(forKey key: String) -> Int {
        defaults.integer(forKey: key)
    }

    func setString(_ value: String, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    func getString(forKey key: String) -> String? {
        defaults.string(forKey: key)
    }

    func setDate(_ value: Date, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    func getDate(forKey key: String) -> Date? {
        defaults.object(forKey: key) as? Date
    }

    func setStringArray(_ value: [String], forKey key: String) {
        defaults.set(value, forKey: key)
    }

    func getStringArray(forKey key: String) -> [String] {
        defaults.stringArray(forKey: key) ?? []
    }

    func setStringSet(_ value: Set<String>, forKey key: String) {
        defaults.set(Array(value), forKey: key)
    }

    func getStringSet(forKey key: String) -> Set<String> {
        Set(defaults.stringArray(forKey: key) ?? [])
    }
}
