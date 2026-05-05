import Foundation

public struct DataTransformer {
  public let encrypt: (Data) -> Data
  public let decrypt: (Data) -> Data
  
  public init(
    encrypt: @escaping (Data) -> Data,
    decrypt: @escaping (Data) -> Data
  ) {
    self.encrypt = encrypt
    self.decrypt = decrypt
  }
}

public struct StorageMigration {
  public let fromKey: String
  public let toKey: String
  
  public init(fromKey: String, toKey: String) {
    self.fromKey = fromKey
    self.toKey = toKey
  }
}

final class InMemoryCache {
  private let cache = NSCache<NSString, NSData>()
  
  func set(_ data: Data, for key: String) {
    cache.setObject(data as NSData, forKey: key as NSString)
  }
  
  func data(for key: String) -> Data? {
    cache.object(forKey: key as NSString) as Data?
  }
  
  func remove(for key: String) {
    cache.removeObject(forKey: key as NSString)
  }
}

public final class SecureStorage: StorageProtocol {
  private let keychainStorage: KeychainStorage
  private let codableStorage: CodableStorage
  private let transformer: DataTransformer?
  private let cache: InMemoryCache?
  private let queue = DispatchQueue(label: "com.storagekit.secure.queue", attributes: .concurrent)
  
  public init(
    keychainStorage: KeychainStorage = KeychainStorage(),
    codableStorage: CodableStorage = CodableStorage(),
    transformer: DataTransformer? = nil,
    enableCaching: Bool = true
  ) {
    self.keychainStorage = keychainStorage
    self.codableStorage = codableStorage
    self.transformer = transformer
    self.cache = enableCaching ? InMemoryCache() : nil
  }
  
  public func save<T: Codable>(_ value: T, for key: String) {
    queue.sync(flags: .barrier) { [weak self] in
      guard let self else { return }
      guard let encoded = self.codableStorage.encodeIfPossible(value) else { return }
      
      let payload = self.transformer?.encrypt(encoded) ?? encoded
      self.cache?.set(payload, for: key)
      self.keychainStorage.save(payload, for: key)
    }
  }
  
  public func fetch<T: Codable>(_ type: T.Type, for key: String) -> T? {
    queue.sync {
      let payload = cache?.data(for: key) ?? keychainStorage.fetch(Data.self, for: key)
      guard let payload else { return nil }
      
      if cache?.data(for: key) == nil {
        cache?.set(payload, for: key)
      }
      
      let decrypted = transformer?.decrypt(payload) ?? payload
      return codableStorage.decodeIfPossible(type, from: decrypted)
    }
  }
  
  public func delete(for key: String) {
    queue.sync(flags: .barrier) { [weak self] in
      self?.cache?.remove(for: key)
      self?.keychainStorage.delete(for: key)
    }
  }
  
  public func migrate(_ migrations: [StorageMigration]) {
    queue.sync(flags: .barrier) { [weak self] in
      guard let self else { return }
      for migration in migrations {
        guard let data = self.keychainStorage.fetch(Data.self, for: migration.fromKey) else { continue }
        self.keychainStorage.save(data, for: migration.toKey)
        self.keychainStorage.delete(for: migration.fromKey)
        self.cache?.remove(for: migration.fromKey)
        self.cache?.set(data, for: migration.toKey)
      }
    }
  }
}
