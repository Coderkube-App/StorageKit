import Foundation

@propertyWrapper
public struct SecureValue<Value: Codable> {
  private let key: String
  private let storage: SecureStorage
  private let lock = NSLock()
  
  public init(
    key: String,
    storage: SecureStorage = StorageKit.shared.secure
  ) {
    self.key = key
    self.storage = storage
  }
  
  public var wrappedValue: Value? {
    get {
      lock.lock()
      defer { lock.unlock() }
      return storage.fetch(Value.self, for: key)
    }
    nonmutating set {
      lock.lock()
      defer { lock.unlock() }
      if let newValue {
        storage.save(newValue, for: key)
      } else {
        storage.delete(for: key)
      }
    }
  }
}
