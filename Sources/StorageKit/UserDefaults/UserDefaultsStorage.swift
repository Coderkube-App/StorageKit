import Foundation

public final class UserDefaultsStorage: StorageProtocol {
  private let userDefaults: UserDefaults
  private let codableStorage: CodableStorage
  private let queue = DispatchQueue(label: "com.storagekit.userdefaults.queue", attributes: .concurrent)
  
  public init(
    userDefaults: UserDefaults = .standard,
    codableStorage: CodableStorage = CodableStorage()
  ) {
    self.userDefaults = userDefaults
    self.codableStorage = codableStorage
  }
  
  public func save<T: Codable>(_ value: T, for key: String) {
    queue.sync(flags: .barrier) { [weak self] in
      guard let self else { return }
      guard let data = self.codableStorage.encodeIfPossible(value) else { return }
      self.userDefaults.set(data, forKey: key)
    }
  }
  
  public func fetch<T: Codable>(_ type: T.Type, for key: String) -> T? {
    queue.sync {
      guard let data = userDefaults.data(forKey: key) else { return nil }
      return codableStorage.decodeIfPossible(type, from: data)
    }
  }
  
  public func delete(for key: String) {
    queue.sync(flags: .barrier) { [weak self] in
      self?.userDefaults.removeObject(forKey: key)
    }
  }
}
