import Foundation

@propertyWrapper
public struct UserDefault<Value: Codable> {
  private let key: String
  private let defaultValue: Value
  private let storage: UserDefaultsStorage
  private let lock = NSLock()
  
  public init(
    key: String,
    defaultValue: Value,
    storage: UserDefaultsStorage = StorageKit.shared.userDefaults
  ) {
    self.key = key
    self.defaultValue = defaultValue
    self.storage = storage
  }
  
  public var wrappedValue: Value {
    get {
      lock.lock()
      defer { lock.unlock() }
      return storage.fetch(Value.self, for: key) ?? defaultValue
    }
    nonmutating set {
      lock.lock()
      defer { lock.unlock() }
      storage.save(newValue, for: key)
    }
  }
}
