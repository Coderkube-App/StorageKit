import XCTest
@testable import StorageKit

final class StorageKitTests: XCTestCase {
  private struct Profile: Codable, Equatable {
    let id: Int
    let name: String
    let isPremium: Bool
  }
  
  private final class MockKeychainHelper: KeychainHelping {
    private var storage: [String: Data] = [:]
    private let lock = NSLock()
    
    func save(data: Data, for key: String) -> Result<Void, StorageError> {
      lock.lock()
      defer { lock.unlock() }
      storage[key] = data
      return .success(())
    }
    
    func fetchData(for key: String) -> Result<Data, StorageError> {
      lock.lock()
      defer { lock.unlock() }
      guard let data = storage[key] else { return .failure(.dataNotFound) }
      return .success(data)
    }
    
    func deleteData(for key: String) -> Result<Void, StorageError> {
      lock.lock()
      defer { lock.unlock() }
      storage.removeValue(forKey: key)
      return .success(())
    }
  }
  
  func testUserDefaultsStorageSavesAndFetchesCodable() {
    let suite = UserDefaults(suiteName: #function)!
    suite.removePersistentDomain(forName: #function)
    let storage = UserDefaultsStorage(userDefaults: suite)
    let key = StorageKey.namespaced("profile", namespace: "tests")
    let profile = Profile(id: 7, name: "Vijay", isPremium: true)
    
    storage.save(profile, for: key)
    let fetched = storage.fetch(Profile.self, for: key)
    
    XCTAssertEqual(fetched, profile)
    storage.delete(for: key)
    XCTAssertNil(storage.fetch(Profile.self, for: key))
  }
  
  func testUserDefaultsSupportsPrimitiveTypes() {
    let suite = UserDefaults(suiteName: #function)!
    suite.removePersistentDomain(forName: #function)
    let storage = UserDefaultsStorage(userDefaults: suite)
    
    storage.save(true, for: "flag")
    storage.save(42, for: "count")
    storage.save("storage-kit", for: "name")
    
    XCTAssertEqual(storage.fetch(Bool.self, for: "flag"), true)
    XCTAssertEqual(storage.fetch(Int.self, for: "count"), 42)
    XCTAssertEqual(storage.fetch(String.self, for: "name"), "storage-kit")
  }
  
  func testKeychainStorageWithMockHelper() {
    let helper = MockKeychainHelper()
    let storage = KeychainStorage(helper: helper)
    
    storage.save("token_abc123", for: StorageKey.authToken.rawValue)
    XCTAssertEqual(storage.fetch(String.self, for: StorageKey.authToken.rawValue), "token_abc123")
    
    storage.delete(for: StorageKey.authToken.rawValue)
    XCTAssertNil(storage.fetch(String.self, for: StorageKey.authToken.rawValue))
  }
  
  func testSecureStorageMigrationMovesVersionedKeys() {
    let helper = MockKeychainHelper()
    let keychain = KeychainStorage(helper: helper)
    let secureStorage = SecureStorage(keychainStorage: keychain, enableCaching: true)
    let oldKey = StorageKey.versioned("authToken", version: 1)
    let newKey = StorageKey.versioned("authToken", version: 2)
    
    secureStorage.save("migrated_token", for: oldKey)
    secureStorage.migrate([StorageMigration(fromKey: oldKey, toKey: newKey)])
    
    XCTAssertNil(secureStorage.fetch(String.self, for: oldKey))
    XCTAssertEqual(secureStorage.fetch(String.self, for: newKey), "migrated_token")
  }
}
