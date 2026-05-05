import Foundation

public final class KeychainStorage: StorageProtocol {
  private let helper: KeychainHelping
  private let codableStorage: CodableStorage
  private let queue = DispatchQueue(label: "com.storagekit.keychain.queue", attributes: .concurrent)
  
  public init(
    helper: KeychainHelping = KeychainHelper(),
    codableStorage: CodableStorage = CodableStorage()
  ) {
    self.helper = helper
    self.codableStorage = codableStorage
  }
  
  public func save<T: Codable>(_ value: T, for key: String) {
    queue.sync(flags: .barrier) { [weak self] in
      guard let self else { return }
      guard let data = self.codableStorage.encodeIfPossible(value) else { return }
      _ = self.helper.save(data: data, for: key)
    }
  }
  
  public func fetch<T: Codable>(_ type: T.Type, for key: String) -> T? {
    queue.sync {
      guard case .success(let data) = helper.fetchData(for: key) else { return nil }
      return codableStorage.decodeIfPossible(type, from: data)
    }
  }
  
  public func delete(for key: String) {
    queue.sync(flags: .barrier) { [weak self] in
      _ = self?.helper.deleteData(for: key)
    }
  }
}
