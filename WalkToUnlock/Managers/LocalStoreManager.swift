import Foundation

class LocalStorageManager: ObservableObject {
    static let shared = LocalStorageManager()
    private let userDefaults = UserDefaults.standard
    
    func setValue<T>(_ value: T, forKey key: String) {
        print("LocalStoremanager.setValue—Set local store key: \(key) to \(value)")
        userDefaults.set(value, forKey: key)
    }
    
    func getValue<T>(forKey key: String, defaultValue: T) -> T {
        print("LocalStoreManager.getValue—Getting value from local store key: \(key)")
        return userDefaults.object(forKey: key) as? T ?? defaultValue
    }
    
    func removeValue(forKey key: String) {
        print("LocalStoreManager.removeValue—Removing value from local store key: \(key)")
        userDefaults.removeObject(forKey: key)
    }
}
